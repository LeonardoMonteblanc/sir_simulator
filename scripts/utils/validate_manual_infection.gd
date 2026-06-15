extends SceneTree

# Testa SEIRDModel.set_initial_infected isoladamente.

func _init():
	var script = load("res://scripts/seird_model.gd")
	if script == null:
		printerr("FAIL load model")
		quit(1)
		return
	# Cenario: 10 agentes, pre-definir 3 como infectados iniciais
	var model = script.new()
	var params = {
		"seed": 7,
		"disease": "Newcastle",
		"num_agents": 10,
		"num_females": 5,
		"vac_coverage": 0.0,
		"initial_infected": [2, 5, 8]
	}
	var adj: Dictionary = {}
	for i in range(10):
		adj[i] = []
	model.initialize(params, adj)
	# espera expostos no estado E
	var contador_E: int = 0
	var ids_infectados_real: Array = []
	for ag in model.agentes:
		if ag.estado == 1:  # Estado.E
			contador_E += 1
			ids_infectados_real.append(ag.id)
	if contador_E != 3:
		printerr("FAIL esperado 3 expostos, teve: ", contador_E, " ids=", ids_infectados_real)
		quit(1)
		return
	if not (2 in ids_infectados_real) or not (5 in ids_infectados_real) or not (8 in ids_infectados_real):
		printerr("FAIL ids esperados [2,5,8] nao batem: ", ids_infectados_real)
		quit(1)
		return
	print("OK initial_infected funcionou: ids=", ids_infectados_real)
	# Cenario: chamada direta do metodo (sem parametro)
	var m2 = script.new()
	var params2 = {
		"seed": 1,
		"disease": "Newcastle",
		"num_agents": 5,
		"num_females": 2,
		"vac_coverage": 0.0  # sem initial_infected -> aleatorio
	}
	var adj2: Dictionary = {}
	for i in range(5):
		adj2[i] = []
	m2.initialize(params2, adj2)
	# verifica que houve pelo menos 1 exposto
	var expostos: int = 0
	for ag in m2.agentes:
		if ag.estado == 1:
			expostos += 1
	if expostos == 0:
		printerr("FAIL sem initial_infected deveria pegar 1 aleatorio")
		quit(1)
		return
	print("OK fallback aleatorio: ", expostos, " expostos (esperado 1)")
	# Cenario: set_initial_infected direto com lista vazia
	var m3 = script.new()
	var params3 = {"seed": 1, "disease": "Newcastle", "num_agents": 5, "num_females": 2, "vac_coverage": 0.0}
	var adj3: Dictionary = {}
	for i in range(5):
		adj3[i] = []
	m3.initialize(params3, adj3)
	m3.set_initial_infected([])
	# nada deve acontecer (estado nao muda)
	print("OK set_initial_infected([]) nao quebra")
	# Cenario: ids invalidos
	m3.set_initial_infected([99, -1, 3])
	# id 3 deve ficar exposto
	var ag3: Object = m3.agentes[3]
	if ag3.estado != 1:
		printerr("FAIL id 3 nao foi exposto")
		quit(1)
		return
	print("OK ignora ids invalidos, expoe id 3")
	print("VALIDATE_MANUAL_INFECTION_OK")
	quit(0)
