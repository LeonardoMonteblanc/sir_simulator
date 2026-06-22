extends SceneTree

func _init():
    var scene = load("res://scenes/mainSimulation.tscn")
    var main = scene.instantiate()
    get_root().add_child(main)
    var view = main.get_node("ColorRect/SimulationView/SimulationView")
    print("Children count:", view.get_child_count())
    for i in range(view.get_child_count()):
        var child = view.get_child(i)
        print(i, ":", child.name, "type", child.get_class())
    quit()
