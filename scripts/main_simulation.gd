# res://scripts/main_simulation.gd
extends Control

# Controlador raiz: media entre modelo, view e HUD.
# Conforme docs/ARCHITECTURE.md: nao modifica logica do core, apenas orquestra.

@onready var view_simulacao = $ColorRect/SimulationView/SimulationView
@onready var hud_interface = $ColorRect/HUD
@onready var view_metricas: Panel = $ColorRect/MetricsView
var parametros_globais: Dictionary = {}

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _ready() -> void:
	# sempre sincroniza com SimConfig no inicio (singleton autoload)
	parametros_globais = SimConfig.params

	# conexoes - usar is_instance_valid para seguranca
	if is_instance_valid(view_simulacao):
		if view_simulacao.has_signal("passo_concluido"):
			view_simulacao.passo_concluido.connect(_distribuir_dados)
		if view_simulacao.has_signal("surto_encerrado"):
			view_simulacao.surto_encerrado.connect(_exibir_relatorio_final)
	if is_instance_valid(hud_interface) and hud_interface.has_signal("solicitar_intervencao"):
		hud_interface.solicitar_intervencao.connect(_processar_intervencao)
	if is_instance_valid(hud_interface) and hud_interface.has_signal("encerrar_simulacao_solicitado"):
		hud_interface.encerrar_simulacao_solicitado.connect(_exibir_relatorio_final)

func _distribuir_dados(dados: Dictionary) -> void:
	if is_instance_valid(hud_interface):
		hud_interface.atualizar_interface(dados)
	# alimenta o grafico de metricas, se a view existir
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
	get_tree().paused = true

	var summary: Dictionary = view_simulacao.modelo_epidemiologico.get_summary()
	var relatorio_scene: Resource = load("res://scenes/relatorio.tscn")
	if relatorio_scene == null:
		printerr("relatorio.tscn nao encontrada")
		return
	var relatorio: Node = relatorio_scene.instantiate()
	add_child(relatorio)
	# popular opcional: so chama se o metodo existir
	if relatorio.has_method("popular"):
		var historico: Dictionary = {}
		if is_instance_valid(view_metricas) and "historico" in view_metricas:
			historico = view_metricas.historico
		relatorio.popular(summary, historico)

	var btn_passo: Button = view_simulacao.get_node_or_null("BtnPasso")
	if btn_passo != null:
		btn_passo.disabled = true
