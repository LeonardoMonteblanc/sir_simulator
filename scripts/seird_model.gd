class_name SEIRDModel
extends RefCounted


# DADOS DAS DOENÇAS ---------------------------------------------------
const DISEASE_PRESETS: Dictionary = {
	"Newcastle": {
		"beta": 0.40,
		"latency_min": 2, "latency_max": 6,
		"infect_min": 5,  "infect_max": 14,
		"delta": 0.70,
		"post_mortem_days": 2
	},
	"HPAI H5N1": {
		"beta": 0.70,
		"latency_min": 1, "latency_max": 3,
		"infect_min": 2,  "infect_max": 5,
		"delta": 0.95,
		"post_mortem_days": 4
	},
	"Marek": {
		"beta": 0.20,
		"latency_min": 14, "latency_max": 21,
		"infect_min": 20,  "infect_max": 60,
		"delta": 0.75,
		"post_mortem_days": 0
	},
	"Bronquite": {
		"beta": 0.60,
		"latency_min": 1, "latency_max": 3,
		"infect_min": 5,  "infect_max": 10,
		"delta": 0.15,
		"post_mortem_days": 0
	}
}

# CLASSE INTERNA: AGENTE ---------------------------------------------------
class Agente:
	var id: int
	var estado: SEIRDModel.Estado
	var dias_estado: int 	# qtd de dias que dura o estado
	var dur_latencia: int	# qtd do 
	var dur_infeccao: int
	var eh_femea: bool
	var prod_ovos_dia: float
	var viva: bool

# ENUM DE ESTADOS ---------------------------------------------------
enum Estado { 
	S, # S -> Sucestivel
	E, # E -> Exposto
	I, # I -> Infectado
	R, # R -> Recuperado
	D  # D -> Morto 
}

# PARÂMETROS DO ALGORITMO SEIR ---------------------------------------------------
var beta: float          	# probabilidade de transmissão por contato por dia
var delta: float         	# probabilidade de morte ao sair de I
var latency_min: int     	# duração mínima em E (dias)
var latency_max: int     	# duração máxima em E (dias)
var infect_min: int      	# duração mínima em I (dias)
var infect_max: int      	# duração máxima em I (dias)
var post_mortem_days: int	# dias de transmissão pós morte

# ESTADO DA SIMULAÇÃO ---------------------------------------------------
var agentes: Array        
var adjacencia: Dictionary  
var dia: int
var rng: RandomNumberGenerator

# ---------------------------------------------------------------------------
# ACUMULADORES E MÉTRICAS ---------------------------------------------------
var ovos_perdidos_hoje: float
var ovos_perdidos_total: float
var qtd_mortos: int
var prejuizo: float

# PARÂMETROS ECONÔMICOS ---------------------------------------------------
var preco_ovo: float
var preco_ave: float

# LOG DE EVENTOS ---------------------------------------------------
var dia_prim_infectado: int
var dia_pico_infectados: int
var qtd_pico_infectados: int
var dia_ult_morte: int

# SINAIS ---------------------------------------------------
signal step_completed(result: Dictionary)

# FUNÇÕES PÚBLICAS ---------------------------------------------------
# função que inicializa os dados para serem usados
func initialize(params: Dictionary, dict_adjacencia: Dictionary):
	# Configuração do gerador de números aleatorios (RNG) + definição de seed
	rng = RandomNumberGenerator.new()
	rng.seed = params.get("seed", 0)
	
	# Carrega as informações das diferentes doenças
	var nm_doenca = params.get("disease", "Newcastle")
	var dados_doenca = DISEASE_PRESETS[nm_doenca]
	
	# Separa os parametros em variaveis para serem melhor acessadas
	beta = dados_doenca["beta"]
	delta = dados_doenca["delta"]
	latency_min = dados_doenca["latency_min"]
	latency_max = dados_doenca["latency_max"]
	infect_min = dados_doenca["infect_min"]
	infect_max = dados_doenca["infect_max"]
	post_mortem_days = dados_doenca["post_mortem_days"]
	
	# Carrega as informações economicas
	preco_ovo = params.get("egg_price", 0.7)
	preco_ave = params.get("bird_price", 30.0)
	
	# Reseta os dados da simulação
	adjacencia = dict_adjacencia
	dia = 0
	agentes.clear()
	ovos_perdidos_total = 0.0
	qtd_mortos = 0
	prejuizo = 0.0
	
	dia_prim_infectado = -1
	dia_pico_infectados = -1
	qtd_pico_infectados = 0
	dia_ult_morte = -1
	
	# Gera os agentes
	var qtde_agentes = params["num_agents"]
	var qtde_femeas = params.get("num_females", int(qtde_agentes)*0.7)
	var cob_vacina = params.get("vac_coverage", 0.0)
	
	for i in range(qtde_agentes):
		var eh_f = i < qtde_femeas
		var ag = Agente.new()
		ag.id = i
		ag.estado = Estado.S
		ag.dias_estado = 0
		ag.eh_femea = eh_f
		ag.viva = true
		ag.prod_ovos_dia = 0.8 if eh_f else 0.0
		agentes.append(ag)
	
	# vacinação inicial
	if cob_vacina > 0:
		var qtde_vacinar = int(floor(cob_vacina * qtde_agentes))
		var agentes_s = _get_agentes_by_state(Estado.S)
		
		for i in range(min(qtde_vacinar, agentes_s.size())):
			if agentes_s.is_empty(): break
			
			var idx = rng.randi() % agentes_s.size()
			agentes_s[idx].estado = Estado.R
			agentes_s.remove_at(idx)
			
	# paciente zero
	var suscetiveis_rest = _get_agentes_by_state(Estado.S)
	if suscetiveis_rest.size() > 0:
		var idx_p_zero = rng.randi() % suscetiveis_rest.size()
		_expose_agent(suscetiveis_rest[idx_p_zero])

# Passa um dia e atualiza:
#  1) Transmissão 
#  2) Avanço de estados
#  3) Cálculo de impacto econômico 
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
		"suscetiveis": contagens["S"],
		"infectados": contagens["I"],
		"recuperados": contagens["R"],
		"mortos": contagens["D"],
		"expostos": contagens["E"],
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

func vaccinate(fracao: float):
	var candidatos = _get_agentes_by_state(Estado.S)
	var qtd_vacinar = int(candidatos.size() * fracao)
	candidatos.shuffle()
	
	for i in range(qtd_vacinar):
		candidatos[i].estado = Estado.R

func isolate_infectious():
	var infectados = _get_agentes_by_state(Estado.I)
	for ag in infectados:
		if adjacencia.has(ag.id):
			adjacencia[ag.id] = []

# contagem de agentes por estado
func _count_states() -> Dictionary:
	var contagens = { "S": 0, "E": 0, "I":0, "R":0, "D":0}
	for ag in agentes:
		match ag.estado:
			Estado.S: contagens["S"] +=1
			Estado.E: contagens["E"] +=1
			Estado.I: contagens["I"] +=1
			Estado.R: contagens["R"] +=1
			Estado.D: contagens["D"] +=1
	return contagens

# expoe o agente ao virus (é exposto)
func _expose_agent(ag: Agente) -> void:
	ag.estado = Estado.E
	ag.dur_latencia = rng.randi_range(latency_min, latency_max)
	ag.dias_estado = 0

#avança o estado de infeção depois do agente exposto
func _update_disease_progress(ag: Agente):
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
		else:
			ag.estado = Estado.R
		ag.dias_estado = 0
	ag.dias_estado += 1

# observa quem são os vizinhos para poder calcular a prob de infecção
func _get_infection_prob(ag: Agente, ids_infectados: Array) -> float:
	var vizinhos = adjacencia.get(ag.id, [])
	
	if vizinhos.is_empty():
		return 0.0
	var prod_nao_infeccao: float = 1.0
	
	for viz in vizinhos:
		var id_viz = viz["neighbor_id"]
		var peso = viz["weight"]
		
		var ag_viz = agentes[id_viz]
		var eh_infectado = false
		
		if ag_viz.estado == Estado.I:
			eh_infectado = true
		elif ag_viz.estado == Estado.D and ag_viz.dias_estado <= post_mortem_days:
			eh_infectado = true
		
		if eh_infectado:
			prod_nao_infeccao *= (1.0 - beta * peso)
	return 1.0 - prod_nao_infeccao
