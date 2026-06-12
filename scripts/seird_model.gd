class_name SEIRDModel
extends RefCounted

const DISEASE_PRESETS: Dictionary = {
	"Newcastle": {
		"beta": 0.40,
		"latency_min": 2, "latency_max": 6,
		"infect_min": 5, "infect_max": 14,
		"delta": 0.70,
		"post_mortem_days": 2
	},
	"HPAI H5N1": {
		"beta": 0.70,
		"latency_min": 1, "latency_max": 3,
		"infect_min": 2, "infect_max": 5,
		"delta": 0.95,
		"post_mortem_days": 4
	},
	"Marek": {
		"beta": 0.20,
		"latency_min": 14, "latency_max": 21,
		"infect_min": 20, "infect_max": 60,
		"delta": 0.75,
		"post_mortem_days": 0
	},
	"Bronquite": {
		"beta": 0.60,
		"latency_min": 1, "latency_max": 3,
		"infect_min": 5, "infect_max": 10,
		"delta": 0.15,
		"post_mortem_days": 0
	}
}

class Agente:
	var id: int
	var estado: SEIRDModel.Estado
	var dias_estado: int
	# duração da latência em dias
	var dur_latencia: int
	var dur_infeccao: int
	var eh_femea: bool
	var prod_ovos_dia: float
	var viva: bool

enum Estado {
	S,
	E,
	I,
	R,
	D
}

var beta: float
var delta: float
var latency_min: int
var latency_max: int
var infect_min: int
var infect_max: int
var post_mortem_days: int

var agentes: Array = []
var adjacencia: Dictionary = {}
var dia: int = 0
var rng: RandomNumberGenerator

var ovos_perdidos_hoje: float = 0.0
var ovos_perdidos_total: float = 0.0
var qtd_mortos: int = 0
var prejuizo: float = 0.0

var preco_ovo: float = 0.0
var preco_ave: float = 0.0

var dia_prim_infectado: int = -1
var dia_pico_infectados: int = -1
var qtd_pico_infectados: int = 0
var dia_ult_morte: int = -1

signal step_completed(result: Dictionary)

func initialize(params: Dictionary, dict_adjacencia: Dictionary) -> void:
	rng = RandomNumberGenerator.new()
	rng.seed = params.get("seed", 0)

	var nm_doenca = params.get("disease", "Newcastle")
	var dados_doenca = DISEASE_PRESETS[nm_doenca]

	beta = dados_doenca["beta"]
	delta = dados_doenca["delta"]
	latency_min = dados_doenca["latency_min"]
	latency_max = dados_doenca["latency_max"]
	infect_min = dados_doenca["infect_min"]
	infect_max = dados_doenca["infect_max"]
	post_mortem_days = dados_doenca["post_mortem_days"]

	preco_ovo = params.get("egg_price", 0.7)
	preco_ave = params.get("bird_price", 30.0)

	adjacencia = dict_adjacencia
	dia = 0
	agentes.clear()
	ovos_perdidos_hoje = 0.0
	ovos_perdidos_total = 0.0
	qtd_mortos = 0
	prejuizo = 0.0
	dia_prim_infectado = -1
	dia_pico_infectados = -1
	qtd_pico_infectados = 0
	dia_ult_morte = -1

	var qtde_agentes = params["num_agents"]
	var qtde_femeas = params.get("num_females", int(qtde_agentes) * 0.7)
	var cob_vacina = params.get("vac_coverage", 0.0)

	for i in range(qtde_agentes):
		var ag = Agente.new()
		ag.id = i
		ag.estado = Estado.S
		ag.dias_estado = 0
		ag.dur_latencia = 0
		ag.dur_infeccao = 0
		ag.eh_femea = i < qtde_femeas
		ag.viva = true
		ag.prod_ovos_dia = 0.8 if ag.eh_femea else 0.0
		agentes.append(ag)

	if cob_vacina > 0.0:
		var qtde_vacinar = int(floor(cob_vacina * qtde_agentes))
		var agentes_s = _get_agentes_by_state(Estado.S)
		for i in range(min(qtde_vacinar, agentes_s.size())):
			if agentes_s.is_empty():
				break
			var idx = rng.randi() % agentes_s.size()
			agentes_s[idx].estado = Estado.R
			agentes_s.remove_at(idx)

	var suscetiveis_rest = _get_agentes_by_state(Estado.S)
	if suscetiveis_rest.size() > 0:
		var idx_p_zero = rng.randi() % suscetiveis_rest.size()
		_expose_agent(suscetiveis_rest[idx_p_zero])

func step() -> Dictionary:
	var ids_infectados: Array = []
	for ag in agentes:
		if ag.estado == Estado.I:
			ids_infectados.append(ag.id)
		elif ag.estado == Estado.D and ag.dias_estado <= post_mortem_days:
			ids_infectados.append(ag.id)

	for ag in agentes:
		if ag.estado == Estado.S:
			var prob = _get_infection_prob(ag, ids_infectados)
			if rng.randf() < prob:
				_expose_agent(ag)
				if dia_prim_infectado == -1:
					dia_prim_infectado = dia

	var infectados_atual: int = 0
	for ag in agentes:
		_update_disease_progress(ag)
		if ag.estado == Estado.I:
			infectados_atual += 1

	if infectados_atual > qtd_pico_infectados:
		qtd_pico_infectados = infectados_atual
		dia_pico_infectados = dia

	var prod_esperada: float = 0.0
	var prod_real: float = 0.0
	for ag in agentes:
		if ag.eh_femea:
			prod_esperada += ag.prod_ovos_dia
			if ag.viva:
				if ag.estado == Estado.S or ag.estado == Estado.E or ag.estado == Estado.R:
					prod_real += ag.prod_ovos_dia
				elif ag.estado == Estado.I:
					prod_real += ag.prod_ovos_dia * 0.5

	var perda_hoje = prod_esperada - prod_real
	ovos_perdidos_total += perda_hoje
	ovos_perdidos_hoje = perda_hoje
	prejuizo = (ovos_perdidos_total * preco_ovo) + (qtd_mortos * preco_ave)
	dia += 1

	var contagens = _count_states()
	var resultado = {
		"dia": dia,
		"suscetiveis": contagens.get("S", 0),
		"infectados": contagens.get("I", 0),
		"recuperados": contagens.get("R", 0),
		"mortos": contagens.get("D", 0),
		"expostos": contagens.get("E", 0),
		"ovos_perdidos_hoje": ovos_perdidos_hoje,
		"ovos_perdidos_total": ovos_perdidos_total,
		"prejuizo": prejuizo
	}

	step_completed.emit(resultado)
	return resultado

# qtd de agentes por estado
func _get_agentes_by_state(estado: Estado) -> Array:
	var encontrados: Array = []
	for ag in agentes:
		if ag.estado == estado:
			encontrados.append(ag)
	return encontrados

func vaccinate(fracao: float) -> void:
	var candidatos = _get_agentes_by_state(Estado.S)
	var qtd_vacinar = int(candidatos.size() * fracao)
	candidatos.shuffle()
	for i in range(qtd_vacinar):
		candidatos[i].estado = Estado.R

func isolate_infectious() -> void:
	var infectados = _get_agentes_by_state(Estado.I)
	var infectados_ids: Array = []
	for ag in infectados:
		infectados_ids.append(ag.id)
	for ag_id in adjacencia.keys():
		if infectados_ids.has(ag_id):
			# esvazia a lista de adjacência do agente isolado
			adjacencia[ag_id].clear()
			continue
		var vizinhos_atuais = adjacencia.get(ag_id, [])
		var novos_vizinhos: Array = []
		for viz in vizinhos_atuais:
			# remove o agente isolado das listas de adjacência dos outros nós
			if not infectados_ids.has(viz.get("neighbor_id")):
				novos_vizinhos.append(viz)
		adjacencia[ag_id] = novos_vizinhos

# contagem de agentes por estado
func _count_states() -> Dictionary:
	var cont_s = 0
	var cont_e = 0
	var cont_i = 0
	var cont_r = 0
	var cont_d = 0
	for ag in agentes:
		if ag.estado == Estado.S:
			cont_s += 1
		elif ag.estado == Estado.E:
			cont_e += 1
		elif ag.estado == Estado.I:
			cont_i += 1
		elif ag.estado == Estado.R:
			cont_r += 1
		elif ag.estado == Estado.D:
			cont_d += 1
	return {"S": cont_s, "E": cont_e, "I": cont_i, "R": cont_r, "D": cont_d}

# expoe o agente ao virus (é exposto)
func _expose_agent(ag: Agente) -> void:
	ag.estado = Estado.E
	ag.dur_latencia = rng.randi_range(latency_min, latency_max)
	ag.dias_estado = 0

#avança o estado de infeção depois do agente exposto
func _update_disease_progress(ag: Agente) -> void:
	# transicao de estado de exposto para infectado
	if ag.estado == Estado.E and ag.dias_estado >= ag.dur_latencia:
		ag.estado = Estado.I
		ag.dur_infeccao = rng.randi_range(infect_min, infect_max)
		ag.dias_estado = 0
	elif ag.estado == Estado.I and ag.dias_estado >= ag.dur_infeccao:
		if rng.randf() < delta:
			ag.estado = Estado.D
			ag.viva = false
			qtd_mortos += 1
			dia_ult_morte = dia
		else:
			ag.estado = Estado.R
		ag.dias_estado = 0
	ag.dias_estado += 1

func _check_outbreak_over() -> bool:
	for ag in agentes:
		if ag.estado == Estado.E or ag.estado == Estado.I:
			return false
	return true

func get_summary() -> Dictionary:
	return {
		"total_aves": agentes.size(),
		"qtd_mortos": qtd_mortos,
		"prejuizo": prejuizo,
		"ovos_perdidos_total": ovos_perdidos_total,
		"dia_pico_infectados": dia_pico_infectados,
		"qtd_pico_infectados": qtd_pico_infectados,
		"dia_prim_infectado": dia_prim_infectado,
		"dia_ult_morte": dia_ult_morte,
		"dia_final": dia
	}

"""Probability follows independent hazard model: p = 1 - ∏(1 - β·w)"""
func _get_infection_prob(ag: Agente, ids_infectados: Array) -> float:
	var vizinhos = adjacencia.get(ag.id, [])
	if vizinhos.is_empty():
		return 0.0
	var prod_nao_infeccao: float = 1.0
	for viz in vizinhos:
		var id_viz = viz.get("neighbor_id")
		var peso = viz.get("weight", 1.0)
		if ids_infectados.has(id_viz):
			prod_nao_infeccao *= (1.0 - beta * peso)
	return 1.0 - prod_nao_infeccao
