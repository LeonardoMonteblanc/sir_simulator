# res://scripts/main_simulation.gd
extends Control

@onready var view_simulacao = $ColorRect/SimulationView/SimulationView
@onready var hud_interface = $ColorRect/HUD
@onready var view_metricas = $ColorRect/HUD/GridMetricas/GridContainer2/HBoxContainer/b
var parametros_globais: Dictionary = {}

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _ready() -> void:
	if parametros_globais.size() <=1:
		parametros_globais = SimConfig.params
		
	view_simulacao.passo_concluido.connect(_distribuir_dados)
	#view_simulacao.surto_encerrado.connect(_exibir_relatorio_final)
	#hud_interface.solicitar_intervencao.connect(_processar_intervencao)
	#hud_interface.encerrar_simulacao_solicitado.connect(_exibir_relatorio_final)
	
func _distribuir_dados(dados: Dictionary) -> void:
	hud_interface.atualizar_interface(dados)
	var total_aves = view_simulacao.modelo_epidemiologico.agentes.size()
	var contagens = {
		"S": dados.get("suscetiveis", 0),
		"E": dados.get("expostos", 0),
		"I": dados.get("infectados", 0),
		"R": dados.get("recuperados", 0),
		"D": dados.get("mortos", 0)
	}
	#view_metricas.adicionar_ponto_grafico(contagens, total_aves)
	

func _processar_intervencao(tipo: String) -> void:
	var modelo = view_simulacao.modelo_epidemiologico
	
	match tipo:
		"vacinar":
			modelo.vaccinate(0.5)
		"isolar":
			modelo.isolate_infectious()
			view_simulacao.atualizar_adjacencia_visual(modelo.adjacencia)
			
	view_simulacao.renderizar_estado_atual()

func _exibir_relatorio_final():
	get_tree().paused = true
	
	var summary = view_simulacao.modelo_epidemiologico.get_summary()
	var relatorio = load("res://scenes/relatorio.tscn").instantiate()
	add_child(relatorio)
	#relatorio.popular(summary, view_metricas.historico)
	view_simulacao.get_node("BtnPasso").disabled = true
