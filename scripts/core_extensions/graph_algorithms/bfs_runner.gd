extends RefCounted

# BFS puro: recebe (adjacencia, id_origem, ids_validos) e retorna:
# {
#   "niveis": {id: nivel},
#   "ordem_visita": [ids],   # ordem em que foram descobertos
#   "arvore": {id_filho: id_pai}
# }
# Sem dependencia de cena; testa direto em utils.

static func executar(adj: Dictionary, origem: int, ids_validos: Array = []) -> Dictionary:
	var resultado: Dictionary = {
		"niveis": {},
		"ordem_visita": [],
		"arvore": {}
	}

	# constroi set rapido de validos se passado
	var validos_set: Dictionary = {}
	if ids_validos.size() > 0:
		for id in ids_validos:
			validos_set[int(id)] = true

	var fila: Array = [origem]
	resultado["niveis"][origem] = 0
	resultado["ordem_visita"].append(origem)

	var idx: int = 0
	while idx < fila.size():
		var atual: int = fila[idx]
		idx += 1
		var nivel_atual: int = resultado["niveis"][atual]
		var vizinhos_raw: Array = adj.get(atual, [])
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
			if resultado["niveis"].has(id_v):
				continue
			resultado["niveis"][id_v] = nivel_atual + 1
			resultado["arvore"][id_v] = atual
			fila.append(id_v)
			resultado["ordem_visita"].append(id_v)

	return resultado

# Retorna maximo nivel (raio BFS a partir da origem)
static func max_nivel(resultado: Dictionary) -> int:
	var mx: int = 0
	for k in resultado["niveis"].keys():
		var n: int = resultado["niveis"][k]
		if n > mx:
			mx = n
	return mx

# Agrupa ids por nivel (para animacao em ondas)
static func por_nivel(resultado: Dictionary) -> Dictionary:
	var grupos: Dictionary = {}
	for k in resultado["niveis"].keys():
		var n: int = resultado["niveis"][k]
		if not grupos.has(n):
			grupos[n] = []
		grupos[n].append(int(k))
	return grupos
