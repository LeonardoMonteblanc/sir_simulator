extends RefCounted

# DFS puro: retorna sequencia de visitados na ordem em que foram descobertos
# + arvore DFS (id_filho -> id_pai) + pilha de "backtrack" implicita na ordem.
# Iterativo (com pilha explicita) para evitar stack overflow em grafos grandes.

static func executar(adj: Dictionary, origem: int, ids_validos: Array = []) -> Dictionary:
	var resultado: Dictionary = {
		"ordem_visita": [],
		"arvore": {},
		"visitados": {}
	}

	var validos_set: Dictionary = {}
	if ids_validos.size() > 0:
		for id in ids_validos:
			validos_set[int(id)] = true

	# pilha com tuplas [no, iterador_interno]
	var pilha: Array = [origem]
	while pilha.size() > 0:
		var atual: int = pilha[pilha.size() - 1]
		if not resultado["visitados"].has(atual):
			resultado["visitados"][atual] = true
			resultado["ordem_visita"].append(atual)
		# pega vizinhos nao visitados
		var vizinhos_raw: Array = adj.get(atual, [])
		var proximo: int = -1
		for v in vizinhos_raw:
			var id_v: int = -1
			if v is Dictionary:
				id_v = int(v.get("neighbor_id", -1))
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
			proximo = id_v
			break
		if proximo >= 0:
			resultado["arvore"][proximo] = atual
			pilha.append(proximo)
		else:
			pilha.pop_back()

	return resultado

# retorna o caminho da origem ate destino seguindo a arvore DFS
static func caminho_para(arvore: Dictionary, destino: int) -> Array:
	var caminho: Array = []
	var atual: int = destino
	while arvore.has(atual):
		caminho.push_front(atual)
		atual = arvore[atual]
	caminho.push_front(atual)  # origem
	return caminho
