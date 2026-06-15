# res://scripts/main_simulation.gd
extends Control

# Controlador raiz: media entre modelo, view, HUD, metricas e features isoladas
# em core_extensions/. Conforme docs/ARCHITECTURE.md: nao modifica logica do core,
# apenas orquestra e injeta dependencias.

const AutoSimControllerScript = preload("res://scripts/core_extensions/auto_simulation/auto_simulation_controller.gd")
const ControlPanelScript = preload("res://scripts/core_extensions/auto_simulation/control_panel.gd")
const ControlPanelScene = preload("res://scripts/core_extensions/auto_simulation/control_panel.tscn")
const InfectionSelectorScript = preload("res://scripts/core_extensions/manual_infection/infection_selector.gd")
const InfectionSelectorScene = preload("res://scripts/core_extensions/manual_infection/infection_selector.tscn")
const GraphRegistryScript = preload("res://scripts/core_extensions/graph_algorithms/graph_registry.gd")
const GraphControlPanelScene = preload("res://scripts/core_extensions/graph_algorithms/graph_control_panel.tscn")
const BFSRunnerScript = preload("res://scripts/core_extensions/graph_algorithms/bfs_runner.gd")
const BFSVisualizerScript = preload("res://scripts/core_extensions/graph_algorithms/bfs_visualizer.gd")
const DFSRunnerScript = preload("res://scripts/core_extensions/graph_algorithms/dfs_runner.gd")
const DFSVisualizerScript = preload("res://scripts/core_extensions/graph_algorithms/dfs_visualizer.gd")

@onready var view_simulacao: Control = $ColorRect/SimulationView/SimulationView
@onready var hud_interface: Control = $ColorRect/HUD
@onready var view_metricas: Panel = $ColorRect/MetricsView

# Features (criadas em runtime; nulas quando a extensao correspondente nao foi anexada)
var _auto_sim_ctrl: Node = null
var _control_panel: PanelContainer = null
var _infection_selector: PanelContainer = null
var _btn_abrir_sel: Button = null
var _graph_registry: Node = null
var _graph_control_panel: PanelContainer = null
var _bfs_visualizer: Node = null
var _btn_bfs: Button = null
var _btn_bfs_cancel: Button = null
var _dfs_visualizer: Node = null
var _btn_dfs: Button = null

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
	# monta feature de selecao manual de infectados
	_montar_manual_infection()
	# monta registry de grafo e painel de reset
	_montar_graph_registry()


# === FEATURE GRAPH REGISTRY + RESET (base para algoritmos) ===
func _montar_graph_registry() -> void:
	_graph_registry = GraphRegistryScript.new()
	_graph_registry.name = "GraphRegistry"
	add_child(_graph_registry)
	if is_instance_valid(view_simulacao) and view_simulacao.has_method("injetar_registry"):
		view_simulacao.injetar_registry(_graph_registry)
	# painel de reset
	_graph_control_panel = GraphControlPanelScene.instantiate() as PanelContainer
	if is_instance_valid(_graph_control_panel):
		_graph_control_panel.name = "GraphControlPanel"
		_graph_control_panel.position = Vector2(640, 10)
		_graph_control_panel.size = Vector2(280, 60)
		add_child(_graph_control_panel)
		_graph_control_panel.reset_pressed.connect(_on_graph_reset)
	# visualizador BFS (feature isolada - se deletar esta secao, BFS some sem quebrar core)
	_bfs_visualizer = BFSVisualizerScript.new()
	_bfs_visualizer.name = "BFSVisualizer"
	add_child(_bfs_visualizer)
	if _bfs_visualizer.has_method("set_registry"):
		_bfs_visualizer.set_registry(_graph_registry)
	# visualizador DFS (feature isolada)
	_montar_dfs()
	# botao BFS: roda BFS a partir do paciente zero (ou primeiro agente exposto/infectado)
	_btn_bfs = Button.new()
	_btn_bfs.text = "BFS a partir do paciente zero"
	_btn_bfs.name = "BtnBFS"
	_btn_bfs.position = Vector2(640, 80)
	_btn_bfs.size = Vector2(280, 32)
	add_child(_btn_bfs)
	_btn_bfs.pressed.connect(_on_bfs_pressed)
	# botao cancelar
	_btn_bfs_cancel = Button.new()
	_btn_bfs_cancel.text = "Cancelar BFS"
	_btn_bfs_cancel.name = "BtnBFSCancel"
	_btn_bfs_cancel.position = Vector2(640, 120)
	_btn_bfs_cancel.size = Vector2(280, 32)
	_btn_bfs_cancel.visible = false
	add_child(_btn_bfs_cancel)
	_btn_bfs_cancel.pressed.connect(_on_bfs_cancel_pressed)

func _on_bfs_pressed() -> void:
	if not is_instance_valid(_bfs_visualizer) or not is_instance_valid(view_simulacao):
		return
	var modelo = view_simulacao.modelo_epidemiologico
	if not is_instance_valid(modelo):
		return
	# escolhe origem: paciente zero, primeiro infectado, ou 0 se nada
	var origem: int = _escolher_origem_bfs()
	if origem < 0:
		printerr("BFS: nenhum no origem encontrado")
		return
	if not _bfs_visualizer.preparar(origem):
		printerr("BFS: preparar falhou")
		return
	# roda todos os niveis de uma vez (animacao instantanea) - usuarios preferencias
	# se quiser passo a passo, trocar por animacao com await
	while _bfs_visualizer.avancar():
		pass  # percorre ate acabar
	_btn_bfs_cancel.visible = false

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

func _on_bfs_cancel_pressed() -> void:
	if is_instance_valid(_bfs_visualizer):
		_bfs_visualizer.cancelar()
	_btn_bfs_cancel.visible = false

# === FEATURE DFS (isolada em core_extensions/graph_algorithms/) ===
func _montar_dfs() -> void:
	_dfs_visualizer = DFSVisualizerScript.new()
	_dfs_visualizer.name = "DFSVisualizer"
	add_child(_dfs_visualizer)
	if _dfs_visualizer.has_method("set_registry"):
		_dfs_visualizer.set_registry(_graph_registry)
	_btn_dfs = Button.new()
	_btn_dfs.text = "DFS a partir do paciente zero"
	_btn_dfs.name = "BtnDFS"
	_btn_dfs.position = Vector2(640, 160)
	_btn_dfs.size = Vector2(280, 32)
	add_child(_btn_dfs)
	_btn_dfs.pressed.connect(_on_dfs_pressed)

func _on_dfs_pressed() -> void:
	if not is_instance_valid(_dfs_visualizer) or not is_instance_valid(view_simulacao):
		return
	var modelo = view_simulacao.modelo_epidemiologico
	if not is_instance_valid(modelo):
		return
	var origem: int = _escolher_origem_bfs()
	if origem < 0:
		printerr("DFS: nenhum no origem encontrado")
		return
	if not _dfs_visualizer.preparar(origem):
		printerr("DFS: preparar falhou")
		return
	# roda todos os passos
	while _dfs_visualizer.avancar():
		pass

func _on_graph_reset() -> void:
	if not is_instance_valid(view_simulacao):
		return
	# limpa marcacoes de algoritmo (cores temporarias)
	if is_instance_valid(_graph_registry) and _graph_registry.has_method("resetar_cores_algoritmo"):
		_graph_registry.resetar_cores_algoritmo()
	# restaura cores SEIRD nos nos (porque o reset do algoritmo deixa a cor
	# SEIRD anterior la, mas a simulacao pode ter avancado desde o registro)
	view_simulacao.renderizar_estado_atual()


# === FEATURE MANUAL INFECTION (isolada em core_extensions/manual_infection/) ===
func _montar_manual_infection() -> void:
	# 1. cria o seletor (invisivel por padrao)
	_infection_selector = InfectionSelectorScene.instantiate() as PanelContainer
	if _infection_selector == null:
		return
	_infection_selector.name = "InfectionSelector"
	_infection_selector.visible = false
	# posiciona centrado aproximado
	_infection_selector.position = Vector2(660, 380)
	_infection_selector.size = Vector2(440, 380)
	add_child(_infection_selector)
	_infection_selector.confirmar_pressed.connect(_on_infection_confirmar)
	_infection_selector.cancelar_pressed.connect(_on_infection_cancelar)
	# 2. cria botao de abrir
	_btn_abrir_sel = Button.new()
	_btn_abrir_sel.text = "Escolher Infectados"
	_btn_abrir_sel.name = "BtnAbrirSelector"
	_btn_abrir_sel.position = Vector2(1052, 460)
	_btn_abrir_sel.size = Vector2(402, 32)
	add_child(_btn_abrir_sel)
	_btn_abrir_sel.pressed.connect(_on_abrir_selector)

func _on_abrir_selector() -> void:
	if not is_instance_valid(view_simulacao) or not is_instance_valid(view_simulacao.modelo_epidemiologico):
		return
	if not is_instance_valid(_infection_selector):
		return
	var modelo = view_simulacao.modelo_epidemiologico
	_infection_selector.popular(modelo.agentes)
	_infection_selector.visible = true

func _on_infection_confirmar(ids: Array) -> void:
	if not is_instance_valid(view_simulacao) or not is_instance_valid(view_simulacao.modelo_epidemiologico):
		return
	var modelo = view_simulacao.modelo_epidemiologico
	# se ids vazio, nao altera (deixa aleatorio); senao aplica
	if ids.is_empty():
		# pega um suscetivel aleatorio para nao ficar sem infectado inicial
		var sus: Array = []
		for ag in modelo.agentes:
			if ag.estado == 0:
				sus.append(ag.id)
		if sus.size() > 0:
			modelo.set_initial_infected([sus[modelo.rng.randi() % sus.size()]])
	else:
		modelo.set_initial_infected(ids)
	view_simulacao.renderizar_estado_atual()
	_infection_selector.visible = false

func _on_infection_cancelar() -> void:
	if is_instance_valid(_infection_selector):
		_infection_selector.visible = false

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
