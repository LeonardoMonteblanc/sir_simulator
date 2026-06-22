extends SceneTree
func _init():
	var scene = load("res://scenes/mainSimulation.tscn")
	var inst = scene.instantiate()
	print("children:", inst.get_child_count())
	quit()
