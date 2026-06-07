class_name GraphGenerator
extends RefCounted

# CONSTANTES DE CONFIGURAÇÃO ---------------------------------------------------
const LARGURA_GRID: float = 1000.0
const ALTURA_GRID: float = 1000.0
const RAIO_CORTE_PADRAO: float = 250.0

# funcao que gera a malha e as posições do grafo
func generate(num_nodes: int, layout: String) -> Dictionary:
	var malha_adjacencia: Dictionary = {}
	var coordenadas_nos: Dictionary = {}
	
	for i in range(num_nodes):
		malha_adjacencia[i] = []
		coordenadas_nos[i] = Vector2.ZERO
		
	var rng:= RandomNumberGenerator.new()
	rng.randomize()
	
	match layout:
		"single_pole":
			_generate_single_pole(num_nodes, malha_adjacencia, coordenadas_nos)
		"two_poles":
			_generate_two_poles(num_nodes, malha_adjacencia, coordenadas_nos, rng)
		"free_range", _:
			_generate_free_range(num_nodes, malha_adjacencia, coordenadas_nos, rng)
	
	_garantir_conectividade(num_nodes, malha_adjacencia, coordenadas_nos)
	
	return {
		"adjacency": malha_adjacencia,
		"positions": coordenadas_nos
	}

# Constrói uma topologia linear onde cada ave se conecta apenas aos vizinhos imediatos
func _generate_single_pole(n: int, adj: Dictionary, pos: Dictionary):
	var espacamento = LARGURA_GRID / float(max(1, n-1))
	
	for i in range(n):
		pos[i] = Vector2(i * espacamento, ALTURA_GRID/2.0)
		
		if i > 0:
			adj[i].append({"neighbor_id": i-1, "weight":1.0})
		
		if i < n-1:
			adj[i].append({"neighbor_id": i+1, "weight": 1.0})

# Constrói dois clusters densos com conexões pontuais de peso reduzido entre eles
func _generate_two_poles(n: int, adj: Dictionary, pos: Dictionary, rng: RandomNumberGenerator):
	var metade = n/2
	var raio_cluster = 150.0
	var centro_a = Vector2(LARGURA_GRID * 0.25, ALTURA_GRID * 0.5)
	var centro_b = Vector2(LARGURA_GRID * 0.75, ALTURA_GRID * 0.5)
	
	for i in range(n):
		var centro = centro_a if i < metade else centro_b
		var angulo = rng.randf() * TAU
		var raio = rng.randf() * raio_cluster
		
		pos[i] = centro + Vector2(cos(angulo), sin(angulo)) * raio
		
	for i in range(n):
		for j in range(i+1, n):
			var mesmos_polos: bool = ((i < metade and j < metade) or (i >= metade and j >= metade))
			
			if mesmos_polos:
				var dist = pos[i].distance_to(pos[j])
				if dist < RAIO_CORTE_PADRAO:
					adj[i].append({"neighbor_id": j, "weight": 1.0})
					adj[j].append({"neighbor_id": i, "weight": 1.0})
	
	var pontes = rng.randi_range(2, 3)
	
	for p in range(pontes):
		var no_a = rng.randi() % metade
		var no_b = metade + (rng.randi() % (n-metade))
		
		adj[no_a].append({"neighbor_id": no_b, "weight": 0.3})
		adj[no_b].append({"neighbor_id": no_a,"weight":0.3})

# Distribui os nós aleatoriamente e pondera o peso de contágio inversamente à distância
func _generate_free_range(n: int, adj: Dictionary, pos: Dictionary, rng: RandomNumberGenerator):
	for i in range(n):
		pos[i] = Vector2(rng.randf()*LARGURA_GRID, rng.randf()*ALTURA_GRID)
	for i in range(n):
		for j in range(i+1, n):
			var dist = pos[i].distance_to(pos[j])
			
			if dist < RAIO_CORTE_PADRAO and dist > 0.0:
				var peso_calculado = clampf(RAIO_CORTE_PADRAO / dist, 0.0, 1.0)
				adj[i].append({"neighbor_id": j, "weight": peso_calculado})
				adj[j].append({"neighbor_id": i, "weight": peso_calculado})

# VALIDAÇÃO DE CONECTIVIDADE ---------------------------------------------------
func _garantir_conectividade(n: int, adj: Dictionary, pos: Dictionary):
	for i in range(n):
		if adj[i].is_empty() and n > 1:
			var no_proximo: int = -1
			var menor_distancia: float = INF
			
			for j in range(n):
				if i == j:
					continue
				
				var dist = pos[i].distance_to(pos[j])
				if dist < menor_distancia:
					menor_distancia = dist
					no_proximo = j
			if no_proximo != -1:
				var peso_conexo = 1.0
				if menor_distancia > 0.0:
					peso_conexo = clampf (RAIO_CORTE_PADRAO / menor_distancia, 0.0, 1.0)
					adj[i].append({"neighbor_id": no_proximo, "weight": peso_conexo})
					adj[no_proximo].append({"neighbor_id": i, "weight": peso_conexo})
