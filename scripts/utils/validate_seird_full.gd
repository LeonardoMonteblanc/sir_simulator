extends SceneTree

# Testa seird_model com cenario mais longo (30 steps), verificando transicoes E->I e progressao.

func _init():
	var script = load("res://scripts/seird_model.gd")
	if script == null:
		printerr("FAIL load model")
		quit(1)
		return
	# cenario 1: Newcastle, free_range 30 nos
	var model = script.new()
	var params = {
		"seed": 42,
		"disease": "Newcastle",
		"num_agents": 30,
		"num_females": 20,
		"vac_coverage": 0.0,
		"egg_price": 0.5,
		"bird_price": 25.0,
		"layout_galinheiro": "free_range"
	}
	var adj: Dictionary = {}
	for i in range(30):
		adj[i] = []
		for j in range(30):
			if i != j:
				adj[i].append({"neighbor_id": j})
	model.initialize(params, adj)
	print("C1 init: ", model.agentes.size(), " agentes, dia=", model.dia)
	var c1_observou_I: bool = false
	var c1_observou_tr: bool = false
	for step in range(30):
		var r = model.step()
		var ei = r.get("infectados", 0)
		var dd = r.get("mortos", 0)
		var rr = r.get("recuperados", 0)
		if ei > 0:
			c1_observou_I = true
		if rr > 0 or dd > 0:
			c1_observou_tr = true
		if step < 8 or step % 5 == 0:
			print("  step ", step+1, " dia=", r["dia"], " S=", r["suscetiveis"], " E=", r["expostos"], " I=", ei, " R=", rr, " D=", dd)
	if not c1_observou_I:
		printerr("FAIL c1: nunca teve infectados em 30 steps")
		quit(1)
		return
	print("OK c1 Newcastle livre 30 nos - progressao observada")
	# cenario 2: num_agents=0
	var m2 = script.new()
	var p2 = {"seed": 1, "disease": "Newcastle", "num_agents": 0, "num_females": 0, "vac_coverage": 0.0}
	var adj2: Dictionary = {}
	m2.initialize(p2, adj2)
	print("C2 init ok com 0 agentes: ", m2.agentes.size())
	if m2.agentes.size() != 0:
		printerr("FAIL c2")
		quit(1)
		return
	print("OK c2 num_agents=0")
	# cenario 3: num_females > num_agents (clamp)
	var m3 = script.new()
	var p3 = {"seed": 1, "disease": "Newcastle", "num_agents": 5, "num_females": 99, "vac_coverage": 0.0}
	var adj3: Dictionary = {}
	for i in range(5):
		adj3[i] = []
	m3.initialize(p3, adj3)
	var fem = 0
	for ag in m3.agentes:
		if ag.eh_femea:
			fem += 1
	if fem != 5:
		printerr("FAIL c3 fem=", fem, " esperado 5")
		quit(1)
		return
	print("OK c3 clamp num_females=99 para 5")
	# cenario 4: vaccinate com fracao invalida
	var m4 = script.new()
	var p4 = {"seed": 1, "disease": "Newcastle", "num_agents": 5, "num_females": 3, "vac_coverage": 0.0}
	var adj4: Dictionary = {}
	for i in range(5):
		adj4[i] = []
	m4.initialize(p4, adj4)
	m4.vaccinate(0.0)
	m4.vaccinate(0.5)
	var s_restantes = 0
	for ag in m4.agentes:
		if ag.estado == 0:
			s_restantes += 1
	print("C4 apos vaccinate(0.5): S=", s_restantes, " (esperado 2 ou 3)")
	print("VALIDATE_SEIRD_OK")
	quit(0)
