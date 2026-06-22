extends SceneTree

func print_tree(node: Node, prefix: String=""):
    print(prefix, node.name)
    for child in node.get_children():
        print_tree(child, prefix + "  ")

func _init():
    var scene = load("res://scenes/mainSimulation.tscn")
    var main = scene.instantiate()
    get_root().add_child(main)
    print("--- Full scene tree ---")
    print_tree(main)
    quit()
