extends SceneTree

# Testa DijkstraRunner puro.

func _init():
	var script = load("res://scripts/core_extensions/graph_algorithms/dijkstra_runner.gd")
	if script == null:
		printerr("FAIL load dijkstra")
		quit(1)
		return
	var DijkstraRunner = script
	# Arvore simples, pesos 1
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
	var res: Dictionary = DijkstraRunner.executar(adj, 0, [0,1,2,3,4,5,6])
	# origem a 0 = 0
	if res["distancias"][0] != 0.0:
		printerr("FAIL dist[0] != 0: ", res["distancias"][0])
		quit(1); return
	# 1 e 2 a distancia 1 (sao vizinhos diretos)
	if res["distancias"][1] != 1.0 or res["distancias"][2] != 1.0:
		printerr("FAIL dist[1/2] != 1: ", res["distancias"][1], " ", res["distancias"][2])
		quit(1); return
	# 3, 4, 5, 6 a distancia 2 (filhos de 1 ou 2)
	for id in [3, 4, 5, 6]:
		if res["distancias"][id] != 2.0:
			printerr("FAIL dist[", id, "] != 2: ", res["distancias"][id])
			quit(1); return
	# pior distancia deve ser 2
	if res["pior_distancia"] != 2.0:
		printerr("FAIL pior_distancia != 2: ", res["pior_distancia"])
		quit(1); return
	if res["pior_caminho"].size() != 3:
		printerr("FAIL pior_caminho tamanho errado: ", res["pior_caminho"])
		quit(1); return
	if res["pior_caminho"][0] != 0:
		printerr("FAIL pior_caminho nao comeca com origem: ", res["pior_caminho"])
		quit(1); return
	print("OK dijkstra arvore")
	# grafo com pesos maiores
	# 0 -> 1 peso 5, 0 -> 2 peso 1, 2 -> 1 peso 1  (caminho menor 0-2-1 = 2)
	var adj2: Dictionary = {
		0: [{"neighbor_id": 1, "weight": 5.0}, {"neighbor_id": 2, "weight": 1.0}],
		1: [{"neighbor_id": 0, "weight": 5.0}],
		2: [{"neighbor_id": 0, "weight": 1.0}, {"neighbor_id": 1, "weight": 1.0}],
		3: []  # desconectado
	}
	var res2: Dictionary = DijkstraRunner.executar(adj2, 0, [0,1,2,3])
	if res2["distancias"][1] != 2.0:
		printerr("FAIL caminho menor 0->2->1 deveria ser 2, mas e ", res2["distancias"][1])
		quit(1); return
	if not res2["distancias"].has(3) or res2["distancias"][3] != INF:
		print("Aviso: no 3 desconectado, esperado sem entrada em distancias")
	print("OK dijkstra com pesos")
	# teste destino especifico
	var caminho_especifico: Array = DijkstraRunner.reconstruir_caminho(res2["predecessores"], 0, 1)
	if caminho_especifico != [0, 2, 1]:
		printerr("FAIL caminho reconstruido: ", caminho_especifico)
		quit(1); return
	print("OK reconstruir caminho: ", caminho_especifico)
	print("VALIDATE_DIJKSTRA_OK")
	quit(0)
