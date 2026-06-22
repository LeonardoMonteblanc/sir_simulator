extends SceneTree

func _init():
    var scene = load("res://scenes/mainSimulation.tscn")
    var main = scene.instantiate()
    get_root().add_child(main)
    var view = main.get_node("ColorRect/SimulationView/SimulationView")
    print("Children of SimulationView:")
    for child in view.get_children():
        print(child.name)
    quit()
