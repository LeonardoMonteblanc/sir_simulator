extends SceneTree

# Testa BFSRunner puro.

func _init():
	var script = load("res://scripts/core_extensions/graph_algorithms/bfs_runner.gd")
	if script == null:
		printerr("FAIL load bfs")
		quit(1)
		return
	var BFSRunner = script
	# Cenario: arvore simples
	#       0
	#      / \
	#     1   2
	#    /|   |\
	#   3 4   5 6
	var adj: Dictionary = {
		0: [{"neighbor_id": 1}, {"neighbor_id": 2}],
		1: [{"neighbor_id": 0}, {"neighbor_id": 3}, {"neighbor_id": 4}],
		2: [{"neighbor_id": 0}, {"neighbor_id": 5}, {"neighbor_id": 6}],
		3: [{"neighbor_id": 1}],
		4: [{"neighbor_id": 1}],
		5: [{"neighbor_id": 2}],
		6: [{"neighbor_id": 2}]
	}
	var ids_validos: Array = [0, 1, 2, 3, 4, 5, 6]
	var res: Dictionary = BFSRunner.executar(adj, 0, ids_validos)
	# verifica niveis
	if res["niveis"][0] != 0:
		printerr("FAIL nivel 0 != 0")
		quit(1); return
	if res["niveis"][1] != 1 or res["niveis"][2] != 1:
		printerr("FAIL nivel 1 != 1 para 1 e 2: ", res["niveis"][1], " ", res["niveis"][2])
		quit(1); return
	if res["niveis"][3] != 2 or res["niveis"][4] != 2 or res["niveis"][5] != 2 or res["niveis"][6] != 2:
		printerr("FAIL nivel 2 errado: ", res["niveis"])
		quit(1); return
	# max nivel
	var mx: int = BFSRunner.max_nivel(res)
	if mx != 2:
		printerr("FAIL max_nivel != 2: ", mx)
		quit(1); return
	# por nivel
	var grupos: Dictionary = BFSRunner.por_nivel(res)
	if grupos[0].size() != 1 or grupos[1].size() != 2 or grupos[2].size() != 4:
		printerr("FAIL grupos tamanho errado: ", grupos)
		quit(1); return
	print("OK bfs arvore")
	# Cenario: ciclo - BFS nao deve travar
	var adj2: Dictionary = {
		0: [1, 2],
		1: [0, 2],
		2: [0, 1, 3],
		3: [2]
	}
	var res2: Dictionary = BFSRunner.executar(adj2, 0, [0, 1, 2, 3])
	if res2["niveis"].size() != 4:
		printerr("FAIL bfs com ciclo visitou ", res2["niveis"].size(), " nos")
		quit(1); return
	if res2["niveis"][3] != 2:
		printerr("FAIL no 3 deveria estar nivel 2: ", res2["niveis"][3])
		quit(1); return
	print("OK bfs ciclo")
	# Cenario: nos desconectados
	var adj3: Dictionary = {
		0: [1],
		1: [0],
		2: [3],
		3: [2]
	}
	var res3: Dictionary = BFSRunner.executar(adj3, 0, [0, 1, 2, 3])
	if res3["niveis"].size() != 2:
		printerr("FAIL bfs desconexo visitou ", res3["niveis"].size())
		quit(1); return
	print("OK bfs desconexo (visita apenas componente conexa)")
	# Cenario: adj com vizinhos como int puro (formato antigo)
	var adj4: Dictionary = {
		0: [1, 2],
		1: [0],
		2: [0]
	}
	var res4: Dictionary = BFSRunner.executar(adj4, 0)
	if res4["niveis"][0] != 0 or res4["niveis"][1] != 1 or res4["niveis"][2] != 1:
		printerr("FAIL adj com int puro: ", res4["niveis"])
		quit(1); return
	print("OK bfs adj formato int")
	print("VALIDATE_BFS_OK")
	quit(0)
