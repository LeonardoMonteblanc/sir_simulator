extends SceneTree

# Testa GraphRegistry isoladamente com structure de nodes fake.

var _cores_seird := {
	"S": Color(0.2, 0.5, 0.3),
	"E": Color(0.8, 0.5, 0.1),
	"I": Color(0.8, 0.2, 0.1)
}

func _criar_no_fake(id: int, cor: Color) -> GraphNode:
	var n := GraphNode.new()
	n.name = str(id)
	n.self_modulate = cor
	root.add_child(n)
	return n

func _init():
	var Script = load("res://scripts/core_extensions/graph_algorithms/graph_registry.gd")
	if Script == null:
		printerr("FAIL load registry")
		quit(1)
		return
	var reg = Script.new()
	root.add_child(reg)
	# cria 5 nos fake
	var ids: Array = [0, 1, 2, 3, 4]
	var nos: Dictionary = {}
	for id in ids:
		var cor: Color = _cores_seird["S"] if id == 2 else _cores_seird["I"]
		nos[id] = _criar_no_fake(id, cor)
		reg.registrar(id, nos[id], cor)
	# set adj
	var adj: Dictionary = {0: [1, 2], 1: [0, 3], 2: [0, 4], 3: [1], 4: [2]}
	reg.set_adjacencia(adj)
	# testa get_todos_ids
	var todos: Array = reg.get_todos_ids()
	if todos.size() != 5:
		printerr("FAIL get_todos_ids retornou ", todos.size())
		quit(1)
		return
	print("OK get_todos_ids=", todos)
	# testa get_adjacencia
	var adj_back: Dictionary = reg.get_adjacencia()
	if adj_back[0].size() != 2:
		printerr("FAIL adj[0] tamanho: ", adj_back[0].size())
		quit(1)
		return
	print("OK get_adjacencia ok")
	# testa cor_temporaria
	reg.cor_temporaria(0, Color.YELLOW)
	if nos[0].self_modulate != Color.YELLOW:
		printerr("FAIL cor_temporaria nao mudou cor visual")
		quit(1)
		return
	print("OK cor_temporaria aplicada")
	# testa resetar_cores_algoritmo
	reg.resetar_cores_algoritmo()
	if nos[0].self_modulate != _cores_seird["I"]:
		printerr("FAIL resetar_cores_algoritmo nao restaurou cor base: ", nos[0].self_modulate)
		quit(1)
		return
	print("OK resetar_cores_algoritmo restaurou cor base")
	print("VALIDATE_REGISTRY_OK")
	quit(0)
