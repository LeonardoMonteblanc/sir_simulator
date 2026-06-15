extends RefCounted

# Dijkstra puro: calcula menor caminho da origem ate todos os outros nos,
# usando pesos das arestas. Em grafo nao-ponderado (todos peso 1) ele se
# comporta como BFS por distancia.

static func executar(adj: Dictionary, origem: int, ids_validos: Array = []) -> Dictionary:
	var resultado: Dictionary = {
		"distancias": {origem: 0.0},
		"predecessores": {},
		"visitados": {},
		"pior_caminho": [],
		"pior_distancia": 0.0,
		"pior_destino": -1
	}

	var validos_set: Dictionary = {}
	if ids_validos.size() > 0:
		for id in ids_validos:
			validos_set[int(id)] = true

	# fila de prioridade simples (array de [dist, id], ordenada por dist)
	# godot nao tem heap nativo; para grafos pequenos (~50 nos) isso basta
	var pq: Array = [[0.0, origem]]

	while pq.size() > 0:
		# pega o de menor distancia
		var idx_menor: int = 0
		var dist_menor: float = pq[0][0]
		for i in range(1, pq.size()):
			if pq[i][0] < dist_menor:
				dist_menor = pq[i][0]
				idx_menor = i
		var entrada: Array = pq[idx_menor]
		pq.remove_at(idx_menor)
		var dist_atual: float = entrada[0]
		var atual: int = entrada[1]

		if resultado["visitados"].has(atual):
			continue
		resultado["visitados"][atual] = true

		var vizinhos_raw: Array = adj.get(atual, [])
		for v in vizinhos_raw:
			var id_v: int = -1
			var peso: float = 1.0
			if v is Dictionary:
				id_v = int(v.get("neighbor_id", -1))
				peso = float(v.get("weight", 1.0))
			elif v is int:
				id_v = v
			elif v is float:
				id_v = int(v)
			if id_v < 0:
				continue
			if validos_set.size() > 0 and not validos_set.has(id_v):
				continue
			if resultado["visitados"].has(id_v):
				continue
			var nova_dist: float = dist_atual + peso
			if not resultado["distancias"].has(id_v) or nova_dist < resultado["distancias"][id_v]:
				resultado["distancias"][id_v] = nova_dist
				resultado["predecessores"][id_v] = atual
				pq.append([nova_dist, id_v])

	# identifica o pior caso (mais distante)
	var pior_id: int = -1
	var pior_dist: float = -1.0
	for id in resultado["distancias"].keys():
		var d: float = resultado["distancias"][id]
		if d > pior_dist and id != origem:
			pior_dist = d
			pior_id = id
	resultado["pior_destino"] = pior_id
	resultado["pior_distancia"] = pior_dist
	# reconstroi caminho ate o pior destino
	if pior_id >= 0:
		resultado["pior_caminho"] = reconstruir_caminho(resultado["predecessores"], origem, pior_id)

	return resultado

static func reconstruir_caminho(preds: Dictionary, origem: int, destino: int) -> Array:
	var caminho: Array = []
	var atual: int = destino
	while atual != origem:
		caminho.push_front(atual)
		if not preds.has(atual):
			return []
		atual = preds[atual]
	caminho.push_front(origem)
	return caminho
