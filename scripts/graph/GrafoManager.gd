extends Node2D
class_name GraphManager

var mapa_nos := {}
var edge_map := {}

var edge_scene = preload("res://scenes/graph/Edge.tscn")


func criar_nos(population_manager):
	for n in mapa_nos.values():
		if is_instance_valid(n):
			n.queue_free()

	mapa_nos.clear()

	var agentes = population_manager.obter_agentes()

	for a in agentes:
		var node = preload("res://scenes/graph/AGraphNode.tscn").instantiate()
		add_child(node)

		node.configurar(a.id, a.estado)

		node.position = Vector2(
			randf_range(80, 320),
			randf_range(80, 320)
		)

		mapa_nos[a.id] = node


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

		# atualiza posição sempre
		edge_map[key].configurar(
			mapa_nos[infectado_id].position,
			mapa_nos[fonte_id].position
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

		if a.estado == sir_estados.Estado.RECUPERADO and b.estado == sir_estados.Estado.RECUPERADO:
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
