extends Node2D
class_name GraphManager

var mapa_nos := {}
var edge_map := {}

var edge_scene = preload("res://scenes/graph/Edge.tscn")
const CENTRO_GRAFO := Vector2(200, 200)
const RAIO_CAMADA := 60.0
const RAIO_NO := 14

var niveis := {}
var filhos_por_no := {}

func criar_nos(population_manager):

	for n in mapa_nos.values():
		if is_instance_valid(n):
			n.queue_free()

	mapa_nos.clear()

	var agentes = population_manager.obter_agentes()

	var infectado_inicial = null

	for a in agentes:
		if a.estado == sir_estados.Estado.INFECTADO:
			infectado_inicial = a
			break

	if infectado_inicial == null:
		return

	var centro = Vector2(300, 300)

	var node_central = preload(
		"res://scenes/graph/AGraphNode.tscn"
	).instantiate()

	add_child(node_central)

	node_central.configurar(
		infectado_inicial.id,
		infectado_inicial.estado
	)

	node_central.position = centro

	mapa_nos[infectado_inicial.id] = node_central

	var outros := []

	for a in agentes:
		if a.id != infectado_inicial.id:
			outros.append(a)

	var raio = 150.0
	var quantidade = outros.size()

	for i in range(quantidade):

		var agente = outros[i]

		var node = preload(
			"res://scenes/graph/AGraphNode.tscn"
		).instantiate()

		add_child(node)

		node.configurar(
			agente.id,
			agente.estado
		)

		var angulo = (TAU * i) / quantidade

		node.position = centro + Vector2(
			cos(angulo),
			sin(angulo)
		) * raio

		mapa_nos[agente.id] = node

func atualizar_nos(population_manager):
	for a in population_manager.obter_agentes():
		if mapa_nos.has(a.id):
			var node = mapa_nos[a.id]
			node.estado = a.estado
			node.atualizar_cor()


func atualizar_arestas(simulation_manager):
	if simulation_manager == null:
		return

	var origem_map = simulation_manager.infectados_origem
	if origem_map == null:
		return

	var agentes = simulation_manager.obter_agentes()
	var to_remove := {}

	# CRIA / ATUALIZA ARESTAS (base histórico de infecção)
	for infectado_id in origem_map.keys():
		var fonte_id = origem_map[infectado_id]
		if not mapa_nos.has(infectado_id):
			continue
		if not mapa_nos.has(fonte_id):
			continue

		var key = _edge_key(infectado_id, fonte_id)

		# cria se não existe
		if not edge_map.has(key):
			var edge = edge_scene.instantiate()
			add_child(edge)
			edge_map[key] = edge

		var pontos = _calcular_extremos_aresta(
			mapa_nos[infectado_id].position,
			mapa_nos[fonte_id].position
		)

		edge_map[key].configurar(
			pontos.inicio,
			pontos.fim
		)

	# MARCA REMOÇÃO: ambos recuperados
	for key in edge_map.keys():
		var ids = key.split("_")
		var a_id = int(ids[0])
		var b_id = int(ids[1])

		if not mapa_nos.has(a_id) or not mapa_nos.has(b_id):
			to_remove[key] = true
			continue

		var a = _get_agente_by_id(agentes, a_id)
		var b = _get_agente_by_id(agentes, b_id)

		if a == null or b == null:
			to_remove[key] = true
			continue

		var infectado_id = max(a_id, b_id)

		if simulation_manager.infectados_origem.has(a_id):
			infectado_id = a_id

		if simulation_manager.infectados_origem.has(b_id):
			infectado_id = b_id

		var infectado = _get_agente_by_id(agentes, infectado_id)

		if infectado != null:
			if infectado.estado == sir_estados.Estado.RECUPERADO:
				to_remove[key] = true

	# REMOVE ARESTAS
	for key in to_remove.keys():
		if edge_map.has(key):
			if is_instance_valid(edge_map[key]):
				edge_map[key].queue_free()
			edge_map.erase(key)


func _get_agente_by_id(agentes: Array, id: int):
	for a in agentes:
		if a.id == id:
			return a
	return null


func _edge_key(a_id: int, b_id: int) -> String:
	return str(min(a_id, b_id)) + "_" + str(max(a_id, b_id))

func atualizar_layout(population_manager):

	var agentes = population_manager.obter_agentes()

	var infectados := []
	var suscetiveis := []
	var recuperados := []

	for a in agentes:
		match a.estado:
			sir_estados.Estado.INFECTADO:
				infectados.append(a)

			sir_estados.Estado.SUSCETIVEL:
				suscetiveis.append(a)

			sir_estados.Estado.RECUPERADO:
				recuperados.append(a)

	var centro = Vector2(300, 300)

	# ======================
	# CENTRO
	# ======================

	var infectado_central = null

	if infectados.size() > 0:
		infectado_central = infectados[0]

		if mapa_nos.has(infectado_central.id):
			mapa_nos[infectado_central.id].position = centro

	# ======================
	# INFECTADOS
	# ======================

	var infectados_restantes := []

	for i in infectados:
		if infectado_central == null:
			infectados_restantes.append(i)
		elif i.id != infectado_central.id:
			infectados_restantes.append(i)

	var raio_infectados = 200.0

	for i in range(infectados_restantes.size()):

		var agente = infectados_restantes[i]

		if not mapa_nos.has(agente.id):
			continue

		var angulo = (TAU * i) / max(1, infectados_restantes.size())

		mapa_nos[agente.id].position = centro + Vector2(
				cos(angulo),
				sin(angulo)
			) * raio_infectados

	# ======================
	# SUSCETÍVEIS
	# ======================

	var raio_suscetiveis = 250.0

	for i in range(suscetiveis.size()):

		var agente = suscetiveis[i]

		if not mapa_nos.has(agente.id):
			continue

		var angulo = (TAU * i) / max(1, suscetiveis.size())

		mapa_nos[agente.id].position =centro + Vector2(
				cos(angulo),
				sin(angulo)
			) * raio_suscetiveis

	# ======================
	# RECUPERADOS
	# ======================

	var raio_recuperados = 300.0

	for i in range(recuperados.size()):

		var agente = recuperados[i]

		if not mapa_nos.has(agente.id):
			continue

		var angulo = (TAU * i) / max(1, recuperados.size())

		mapa_nos[agente.id].position = centro + Vector2(
				cos(angulo),
				sin(angulo)
			) * raio_recuperados


func _calcular_extremos_aresta(
	pos_a: Vector2,
	pos_b: Vector2
) -> Dictionary:

	var dir = (pos_b - pos_a).normalized()

	return {
		"inicio": pos_a + dir * RAIO_NO,
		"fim": pos_b - dir * RAIO_NO
	}
