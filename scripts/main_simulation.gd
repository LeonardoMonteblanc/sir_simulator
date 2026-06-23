extends Control


@onready var view_simulacao: Control = $ColorRect/SimulationView2
@onready var hud_interface: PanelContainer = $ColorRect/HUD

const AutoSimController = preload("res://scripts/auto_simulation_controller.gd"
)
var _auto_sim_ctrl: AutoSimController

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _ready() -> void:
	_conectar_sinais_view()
	_conectar_sinais_hud()
	_montar_auto_sim()
	_conectar_config_screen()


func _escolher_origem_bfs() -> int:
	if not is_instance_valid(view_simulacao):
		return -1
	var modelo = view_simulacao.modelo_epidemiologico
	if not is_instance_valid(modelo):
		return -1
	# 1) procura primeiro agente no estado E ou I
	for ag in modelo.agentes:
		if ag.estado == 1 or ag.estado == 2:
			return ag.id
	# 2) senao usa o primeiro id registrado
	if modelo.agentes.size() > 0:
		return modelo.agentes[0].id
	return -1


func _singleton_exists(nome: String) -> bool:
	var root: Node = get_tree().root if get_tree() else null
	if root == null:
		return false
	return root.has_node(nome)

func _conectar_sinais_view() -> void:
	if not is_instance_valid(view_simulacao):
		return
	if view_simulacao.has_signal("passo_concluido"):
		view_simulacao.passo_concluido.connect(_distribuir_dados)
	if view_simulacao.has_signal("surto_encerrado"):
		view_simulacao.surto_encerrado.connect(_exibir_relatorio_final)

func _conectar_sinais_hud() -> void:
	if not is_instance_valid(hud_interface):
		return
		
	if hud_interface.has_signal("play_pressed"):
		hud_interface.play_pressed.connect(_on_autosim_play)
	if hud_interface.has_signal("pause_pressed"):
		hud_interface.pause_pressed.connect(_on_autosim_pause)
	if hud_interface.has_signal("stop_pressed"):
		hud_interface.stop_pressed.connect(_on_autosim_stop)

func _montar_auto_sim() -> void:
	if not is_instance_valid(view_simulacao):
		return

	_auto_sim_ctrl = AutoSimController.new()
	_auto_sim_ctrl.name = "AutoSimController"
	add_child(_auto_sim_ctrl)

	if view_simulacao.has_method("injetar_autosim"):
		view_simulacao.injetar_autosim(_auto_sim_ctrl)

	if is_instance_valid(hud_interface) and hud_interface.has_method("set_estado"):
		hud_interface.set_estado(false, false)

func _conectar_config_screen() -> void:
	var config_screen = $ColorRect/ConfigScreen
	if not is_instance_valid(config_screen):
		return
	if config_screen.has_signal("simulacao_configurada"):
		config_screen.simulacao_configurada.connect(_on_config_finalizada)

func _on_config_finalizada(num_agents: int, disease: String, layout: String) -> void:
	var config_screen = $ColorRect/ConfigScreen
	if is_instance_valid(config_screen):
		config_screen.visible = false
	
	if is_instance_valid(view_simulacao) and view_simulacao.has_method("inicializar_com_config"):
		view_simulacao.inicializar_com_config({
			"num_agents": num_agents,
			"disease": disease,
			"layout": layout
		})

func _on_autosim_play() -> void:
	if not is_instance_valid(view_simulacao):
		return
	if view_simulacao.has_method("resume_autosim"):
		view_simulacao.resume_autosim()
	if view_simulacao.has_method("start_autosim"):
		view_simulacao.start_autosim(1.0)
	_sync_estado_autosim()

func _on_autosim_pause() -> void:
	if is_instance_valid(view_simulacao) and view_simulacao.has_method("pause_autosim"):
		view_simulacao.pause_autosim()
	_sync_estado_autosim()

func _on_autosim_stop() -> void:
	if is_instance_valid(view_simulacao) and view_simulacao.has_method("stop_autosim"):
		view_simulacao.stop_autosim()
	_sync_estado_autosim()

func _on_autosim_speed(speed_seconds: float) -> void:
	if is_instance_valid(view_simulacao) and view_simulacao.has_method("set_speed_autosim"):
		view_simulacao.set_speed_autosim(speed_seconds)

# Reflete estado do controller nos botoes do HUD
func _sync_estado_autosim() -> void:
	if not is_instance_valid(_auto_sim_ctrl):
		return
	if not (is_instance_valid(hud_interface) and hud_interface.has_method("set_estado")):
		return
	var rodando: bool = _auto_sim_ctrl.is_running()
	var pausado: bool = _auto_sim_ctrl.is_paused()
	hud_interface.set_estado(rodando, pausado)

# === DISTRIBUICAO DE DADOS ===
func _distribuir_dados(dados: Dictionary) -> void:
	if is_instance_valid(hud_interface):
		hud_interface.atualizar_interface(dados)

func _exibir_relatorio_final() -> void:
	if not is_instance_valid(view_simulacao) or not is_instance_valid(view_simulacao.modelo_epidemiologico):
		return
	# encerra auto-sim tambem
	if is_instance_valid(view_simulacao) and view_simulacao.has_method("stop_autosim"):
		view_simulacao.stop_autosim()
	_sync_estado_autosim()
	get_tree().paused = true

	var summary: Dictionary = view_simulacao.modelo_epidemiologico.get_summary()
	var relatorio_scene: Resource = load("res://scenes/relatorio.tscn")
	if relatorio_scene == null:
		printerr("relatorio.tscn nao encontrada")
		return
	var relatorio: Node = relatorio_scene.instantiate()
	add_child(relatorio)
	if relatorio.has_method("popular"):
		# relatorio.gd aceita historico opcional; quando ausente, ele se desenha sem timeline
		var historico: Dictionary = {}
		relatorio.popular(summary, historico)
