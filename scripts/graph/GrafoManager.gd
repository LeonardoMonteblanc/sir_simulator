extends Node

var mapa_nos := {}
var contato_ativos := {}

func criar_nos(population_manager):
	var agentes = population_manager.obter_agentes()

	for a in agentes:
		var node = preload("res://scenes/graph/GraphView.tscn").instantiate()
		add_child(node)

		mapa_nos[a.id] = node
		node.configurar(a.id, a.estado)

func atualizar_estado(agente: Agente):
	if not mapa_nos.has(agente.id):
		return

	var node: AGraphNode = mapa_nos[agente.id]
	node.configurar(agente.id, agente.estado)

func detectar_contatos(population_manager):
	var agentes = population_manager.obter_agentes()
	contato_ativos.clear()
	
	for i in range(agentes.size()):
		var a = agentes[i]
		
		for j in range(i+1, agentes.size()):
			var b = agentes[j]
			
			if a.calcular_distancia(b) <= Constants.RAIO_CONTAGIO:
				var chave = _gerar_chave(a.id, b.id)
				contato_ativos[chave] = {
					"a": a.id,
					"b": b.id
				}

func _gerar_chave(id1: int, id2:int) ->String:
	if id1 < id2:
		return str(id1) + "_" + str(id2)
	return str(id2) + "_" + str(id1)
