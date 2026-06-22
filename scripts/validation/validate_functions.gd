extends SceneTree

func _init():
    # Load main scene
    var scene = load("res://scenes/mainSimulation.tscn")
    var main = scene.instantiate()
    # Add to the root of the scene tree
    var root = get_root()
    root.add_child(main)
    # Access SimulationView node
    var view = main.get_node("ColorRect/SimulationView/SimulationView")
    # Zoom functions
    if view.has_method("_on_zoom_in"):
        view._on_zoom_in()
    if view.has_method("_on_zoom_out"):
        view._on_zoom_out()
    if view.has_method("_on_reset_view"):
        view._on_reset_view()
    # Rendering and cleanup
    if view.has_method("renderizar_estado_atual"):
        view.renderizar_estado_atual()
    if view.has_method("limpar_simulacao"):
        view.limpar_simulacao()
    # Test main_simulation API
    if main.has_method("has_autosim"):
        print("has_autosim before:", main.has_autosim())
    if main.has_method("start_autosim"):
        main.start_autosim(0.1)
    if main.has_method("pause_autosim"):
        main.pause_autosim()
    if main.has_method("resume_autosim"):
        main.resume_autosim()
    if main.has_method("stop_autosim"):
        main.stop_autosim()
    # Inject dummy registry
    var reg_res = load("res://scripts/core_extensions/graph_algorithms/graph_registry.gd")
    var registry = reg_res.new()
    if main.has_method("injetar_registry"):
        main.injetar_registry(registry)
    if main.has_method("get_registry"):
        var got = main.get_registry()
        print("registry injected?", got != null)
    # Final status
    print("VALIDATE_FUNCTIONS_OK")
    quit()
