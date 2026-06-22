extends Control


@onready var view_simulacao: Control = $ColorRect/Layout/SidebarLeft/SimulationView/SimulationView
@onready var hud_interface: PanelContainer = $ColorRect/Layout/SidebarRight/HUD
var _auto_sim_ctrl: Node = null

var parametros_globais: Dictionary = {}

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _ready() -> void:
	if _singleton_exists("SimConfig"):
		parametros_globais = SimConfig.params
	else:
		parametros_globais = {}

	_conectar_sinais_view()
	_conectar_sinais_hud()

	# monta feature de auto-sim (controller de timer + injecao na view)
	_montar_auto_sim()
	# monta feature de selecao manual de infectados
	#_montar_manual_infection()
	# monta registry de grafo e painel de reset
	#_montar_graph_registry()




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



#func _on_graph_reset() -> void:
	#if not is_instance_valid(view_simulacao):
		#return
	## limpa marcacoes de algoritmo (cores temporarias)
	#if is_instance_valid(_graph_registry) and _graph_registry.has_method("resetar_cores_algoritmo"):
		#_graph_registry.resetar_cores_algoritmo()
	## restaura cores SEIRD nos nos (porque o reset do algoritmo deixa a cor
	## SEIRD anterior la, mas a simulacao pode ter avancado desde o registro)
	#view_simulacao.renderizar_estado_atual()





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
	# autoplay (HUD absorveu o control_panel)
	if hud_interface.has_signal("play_pressed"):
		hud_interface.play_pressed.connect(_on_autosim_play)
	if hud_interface.has_signal("pause_pressed"):
		hud_interface.pause_pressed.connect(_on_autosim_pause)
	if hud_interface.has_signal("stop_pressed"):
		hud_interface.stop_pressed.connect(_on_autosim_stop)
	if hud_interface.has_signal("speed_changed"):
		hud_interface.speed_changed.connect(_on_autosim_speed)

# === FEATURE AUTO-SIM (controller de timer + injecao na view) ===
func _montar_auto_sim() -> void:
	if not is_instance_valid(view_simulacao):
		return
	# 1. cria e anexa o controller
	_auto_sim_ctrl.name = "AutoSimController"
	add_child(_auto_sim_ctrl)

	# 2. injeta na view (a view passa a escutar o signal tick)
	if view_simulacao.has_method("injetar_autosim"):
		view_simulacao.injetar_autosim(_auto_sim_ctrl)

	# 3. botoes de autoplay estao dentro do HUD (control_panel foi absorvido).
	#    Estado inicial: tudo parado, apenas PLAY habilitado
	if is_instance_valid(hud_interface) and hud_interface.has_method("set_estado"):
		hud_interface.set_estado(false, false)

func _on_autosim_play() -> void:
	if not is_instance_valid(view_simulacao):
		return
	# velocidade inicial 1s por dia; se ja rodando, retoma
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
	# reativa botao manual
	var sim_v = view_simulacao
	if sim_v != null and is_instance_valid(sim_v) and sim_v.has_node("BtnPasso"):
		var b: Button = sim_v.get_node("BtnPasso")
		b.disabled = false
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

	var btn_passo: Button = view_simulacao.get_node_or_null("BtnPasso")
	if btn_passo != null:
		btn_passo.disabled = true
