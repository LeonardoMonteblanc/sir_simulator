# res://scripts/main_simulation.gd
extends Control

# Controlador raiz: media entre modelo, view, HUD, metricas e features isoladas
# em core_extensions/. Conforme docs/ARCHITECTURE.md: nao modifica logica do core,
# apenas orquestra e injeta dependencias.

const AutoSimControllerScript = preload("res://scripts/core_extensions/auto_simulation/auto_simulation_controller.gd")
const ControlPanelScript = preload("res://scripts/core_extensions/auto_simulation/control_panel.gd")
const ControlPanelScene = preload("res://scripts/core_extensions/auto_simulation/control_panel.tscn")

@onready var view_simulacao: Control = $ColorRect/SimulationView/SimulationView
@onready var hud_interface: Control = $ColorRect/HUD
@onready var view_metricas: Panel = $ColorRect/MetricsView

# Features (criadas em runtime; nulas quando a extensao correspondente nao foi anexada)
var _auto_sim_ctrl: Node = null
var _control_panel: PanelContainer = null

var parametros_globais: Dictionary = {}

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _ready() -> void:
	# sempre sincroniza com SimConfig no inicio (singleton autoload)
	if _singleton_exists("SimConfig"):
		parametros_globais = SimConfig.params
	else:
		parametros_globais = {}

	# conexoes - usar is_instance_valid para seguranca
	_conectar_sinais_view()
	_conectar_sinais_hud()

	# monta feature de auto-sim
	_montar_auto_sim()

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
	if hud_interface.has_signal("solicitar_intervencao"):
		hud_interface.solicitar_intervencao.connect(_processar_intervencao)
	if hud_interface.has_signal("encerrar_simulacao_solicitado"):
		hud_interface.encerrar_simulacao_solicitado.connect(_exibir_relatorio_final)

# === FEATURE AUTO-SIM (isolada em core_extensions/auto_simulation/) ===
func _montar_auto_sim() -> void:
	if not is_instance_valid(view_simulacao):
		return
	# 1. cria e anexa o controller
	_auto_sim_ctrl = AutoSimControllerScript.new()
	_auto_sim_ctrl.name = "AutoSimController"
	add_child(_auto_sim_ctrl)

	# 2. injeta na view (a view passa a escutar o signal tick)
	if view_simulacao.has_method("injetar_autosim"):
		view_simulacao.injetar_autosim(_auto_sim_ctrl)

	# 3. instancia o painel de controles e adiciona na cena
	_control_panel = ControlPanelScene.instantiate() as PanelContainer
	if _control_panel != null:
		_control_panel.name = "AutoSimPanel"
		# posiciona abaixo da HUD
		_control_panel.position = Vector2(1052, 500)
		_control_panel.size = Vector2(402, 100)
		add_child(_control_panel)
		# 4. conecta botoes
		_control_panel.play_pressed.connect(_on_autosim_play)
		_control_panel.pause_pressed.connect(_on_autosim_pause)
		_control_panel.stop_pressed.connect(_on_autosim_stop)
		_control_panel.speed_changed.connect(_on_autosim_speed)

func _on_autosim_play() -> void:
	if not is_instance_valid(view_simulacao):
		return
	# velocidade inicial 1s por dia; se ja rodando, retoma
	if view_simulacao.has_method("resume_autosim"):
		view_simulacao.resume_autosim()
	if view_simulacao.has_method("start_autosim"):
		view_simulacao.start_autosim(1.0)

func _on_autosim_pause() -> void:
	if is_instance_valid(view_simulacao) and view_simulacao.has_method("pause_autosim"):
		view_simulacao.pause_autosim()

func _on_autosim_stop() -> void:
	if is_instance_valid(view_simulacao) and view_simulacao.has_method("stop_autosim"):
		view_simulacao.stop_autosim()
	# reativa botao manual
	if view_simulacao and view_simulacao.has_node("BtnPasso"):
		var b: Button = view_simulacao.get_node("BtnPasso")
		b.disabled = false

func _on_autosim_speed(speed_seconds: float) -> void:
	if is_instance_valid(view_simulacao) and view_simulacao.has_method("set_speed_autosim"):
		view_simulacao.set_speed_autosim(speed_seconds)

# === DISTRIBUICAO DE DADOS ===
func _distribuir_dados(dados: Dictionary) -> void:
	if is_instance_valid(hud_interface):
		hud_interface.atualizar_interface(dados)
	if is_instance_valid(view_metricas) and view_metricas.has_method("adicionar_ponto_grafico"):
		if is_instance_valid(view_simulacao) and is_instance_valid(view_simulacao.modelo_epidemiologico):
			var total_aves: int = view_simulacao.modelo_epidemiologico.agentes.size()
			var contagens: Dictionary = {
				"S": dados.get("suscetiveis", 0),
				"E": dados.get("expostos", 0),
				"I": dados.get("infectados", 0),
				"R": dados.get("recuperados", 0),
				"D": dados.get("mortos", 0)
			}
			view_metricas.adicionar_ponto_grafico(contagens, total_aves)

func _processar_intervencao(tipo: String) -> void:
	if not is_instance_valid(view_simulacao):
		return
	var modelo = view_simulacao.modelo_epidemiologico
	if not is_instance_valid(modelo):
		return

	match tipo:
		"vacinar":
			modelo.vaccinate(0.5)
		"isolar":
			modelo.isolate_infectious()
			view_simulacao.atualizar_adjacencia_visual(modelo.adjacencia)

	view_simulacao.renderizar_estado_atual()

func _exibir_relatorio_final() -> void:
	if not is_instance_valid(view_simulacao) or not is_instance_valid(view_simulacao.modelo_epidemiologico):
		return
	# encerra auto-sim tambem
	if is_instance_valid(view_simulacao) and view_simulacao.has_method("stop_autosim"):
		view_simulacao.stop_autosim()
	get_tree().paused = true

	var summary: Dictionary = view_simulacao.modelo_epidemiologico.get_summary()
	var relatorio_scene: Resource = load("res://scenes/relatorio.tscn")
	if relatorio_scene == null:
		printerr("relatorio.tscn nao encontrada")
		return
	var relatorio: Node = relatorio_scene.instantiate()
	add_child(relatorio)
	if relatorio.has_method("popular"):
		var historico: Dictionary = {}
		if is_instance_valid(view_metricas) and "historico" in view_metricas:
			historico = view_metricas.historico
		relatorio.popular(summary, historico)

	var btn_passo: Button = view_simulacao.get_node_or_null("BtnPasso")
	if btn_passo != null:
		btn_passo.disabled = true
