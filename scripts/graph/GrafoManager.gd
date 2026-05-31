extends Node

var mapa_nos := {}

func criar_nos(population_manager):
	var agentes = population_manager.obter_agentes()

	for a in agentes:
		var node = preload("res://scenes/graph/AGraphNode.tscn").instantiate()
		add_child(node)

		mapa_nos[a.id] = node
		node.configurar(a.id, a.estado)

func atualizar_estado(agente: Agente):
	if not mapa_nos.has(agente.id):
		return

	var node: AGraphNode = mapa_nos[agente.id]
	node.configurar(agente.id, agente.estado)
