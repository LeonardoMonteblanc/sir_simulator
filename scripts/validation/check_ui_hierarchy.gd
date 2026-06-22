extends SceneTree

func _init():
	var scene = load("res://scenes/mainSimulation.tscn")
	if scene == null:
		print("FAIL: mainSimulation.tscn nao pode ser carregada")
		quit(1)
		return
	var main = scene.instantiate()
	get_root().add_child(main)
	await process_frame
	var cr = main.get_node_or_null("ColorRect")
	if cr == null:
		print("FAIL: ColorRect nao encontrado")
		quit(1)
		return
	var view = main.get_node_or_null("ColorRect/Layout/SidebarLeft/SimulationView/SimulationView")
	if view == null:
		print("FAIL: SimulationView nao encontrado no main")
		quit(1)
		return
	print("OK: view found at", view.get_path())
	print("v_children=", view.get_child_count())
	for i in range(view.get_child_count()):
		var c = view.get_child(i)
		print("  - ", c.name, " [", c.get_class(), "]")
	var hud = main.get_node_or_null("ColorRect/Layout/SidebarRight/HUD")
	if hud == null:
		print("FAIL: HUD nao encontrado")
		quit(1)
		return
	print("OK: HUD found at", hud.get_path())
	print("hud_children=", hud.get_child_count())
	for i in range(hud.get_child_count()):
		var c = hud.get_child(i)
		print("  - ", c.name, " [", c.get_class(), "]")
	var mv = main.get_node_or_null("ColorRect/Layout/SidebarRight/MetricsView")
	if mv == null:
		print("FAIL: MetricsView nao encontrado")
		quit(1)
		return
	print("OK: MetricsView found at", mv.get_path())
	# simulation view children
	var grp = view.get_node_or_null("TopBar/ZoomGroup")
	if grp == null:
		print("FAIL: TopBar/ZoomGroup nao encontrado")
		quit(1)
		return
	print("OK: ZoomGroup found")
	var ge = view.get_node_or_null("GraphContainer/GraphEdit")
	if ge == null:
		print("FAIL: GraphEdit nao encontrado")
		quit(1)
		return
	print("OK: GraphEdit found")
	var bp = view.get_node_or_null("BottomBar/BtnPasso")
	if bp == null:
		print("FAIL: BtnPasso nao encontrado")
		quit(1)
		return
	print("OK: BtnPasso found")
	print("ALL_VALIDATION_OK")
	quit()
