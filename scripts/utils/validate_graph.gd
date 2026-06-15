extends SceneTree

func _init():
	var script = load("res://scripts/graph_generator.gd")
	if script == null:
		printerr("FAIL load")
		quit(1)
		return
	var g = script.new()
	# teste 1: num_nodes = 0
	var r0 = g.generate(0, "free_range")
	if r0["adjacency"].size() != 0:
		printerr("FAIL num_nodes=0 retornou dicionario nao vazio")
		quit(1)
		return
	print("OK num_nodes=0")
	# teste 2: free_range 20 nos
	var r1 = g.generate(20, "free_range")
	if r1["adjacency"].size() != 20:
		printerr("FAIL adj != 20")
		quit(1)
		return
	# verifica que todos nos tem pelo menos 1 vizinho (conectividade)
	for i in range(20):
		if r1["adjacency"][i].is_empty():
			printerr("FAIL no ", i, " isolado")
			quit(1)
			return
	print("OK free_range 20 nos todos conectados")
	# teste 3: single_pole
	var r2 = g.generate(15, "single_pole")
	print("OK single_pole 15 nos adj=", r2["adjacency"].size())
	# teste 4: two_poles
	var r3 = g.generate(10, "two_poles")
	print("OK two_poles 10 nos adj=", r3["adjacency"].size())
	# verifica sem duplicatas dentro de cada lista
	for i in range(10):
		var vizinhos: Array = r3["adjacency"][i]
		var ids: Array = []
		for v in vizinhos:
			var nid = v.get("neighbor_id", -1)
			if nid in ids:
				printerr("FAIL duplicata: no ", i, " tem vizinho repetido ", nid)
				quit(1)
				return
			ids.append(nid)
	print("OK two_poles sem duplicatas")
	print("VALIDATE_GRAPH_OK")
	quit(0)
