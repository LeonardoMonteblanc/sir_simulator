extends SceneTree

# Testa DFSRunner puro.

func _init():
	var script = load("res://scripts/core_extensions/graph_algorithms/dfs_runner.gd")
	if script == null:
		printerr("FAIL load dfs")
		quit(1)
		return
	var DFSRunner = script
	# Mesmo arvore do BFS para comparar
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
	var res: Dictionary = DFSRunner.executar(adj, 0, ids_validos)
	# verifica que visitou TODOS os 7
	if res["ordem_visita"].size() != 7:
		printerr("FAIL dfs visitou ", res["ordem_visita"].size(), " nos (esperado 7)")
		quit(1); return
	if res["ordem_visita"][0] != 0:
		printerr("FAIL dfs primeiro no != 0: ", res["ordem_visita"])
		quit(1); return
	print("OK dfs visitou todos os ", res["ordem_visita"].size())
	# testa caminho_para
	var arvore: Dictionary = res["arvore"]
	var caminho: Array = DFSRunner.caminho_para(arvore, 3)
	# 3 deve ter 1 como pai, que tem 0 como pai
	print("OK caminho_para(3): ", caminho)
	# tamanho esperado: 0 -> 1 -> 3 = 3 elementos
	if caminho.size() != 3:
		printerr("FAIL caminho tamanho != 3: ", caminho)
		quit(1); return
	if caminho[0] != 0 or caminho[1] != 1 or caminho[2] != 3:
		printerr("FAIL caminho errado: ", caminho)
		quit(1); return
	# teste ciclo
	var adj2: Dictionary = {
		0: [1, 2],
		1: [0, 2],
		2: [0, 1, 3],
		3: [2]
	}
	var res2: Dictionary = DFSRunner.executar(adj2, 0, [0, 1, 2, 3])
	if res2["ordem_visita"].size() != 4:
		printerr("FAIL dfs ciclo visitou ", res2["ordem_visita"].size())
		quit(1); return
	print("OK dfs ciclo")
	print("VALIDATE_DFS_OK")
	quit(0)
