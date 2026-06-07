# res://scripts/main_simulation.gd
extends Control

@onready var view_simulacao = $HBoxContainer/SimulationView
@onready var hud_interface = $HUD
@onready var view_metricas = $HBoxContainer/MetricsView
@onready var relatorio_dialog: AcceptDialog = $RelatorioDialog

var parametros_globais: Dictionary = {}
var modelo_epidemiologico: SEIRDModel

func _ready() -> void:
	if parametros_globais.size() <=1:
		parametros_globais = SimConfig.params
		
	if not modelo_epidemiologico:
		modelo_epidemiologico = SEIRDModel.new()
		
	view_simulacao.passo_concluido.connect(_distribuir_dados)
	hud_interface.solicitar_intervencao.connect(_processar_intervencao)
	hud_interface.encerrar_simulacao_solicitado.connect(_exibir_relatorio_final)
	
func _distribuir_dados(dados: Dictionary) -> void:
	hud_interface.atualizar_interface(dados)
	view_metricas.adicionar_ponto_grafico(dados)
	

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
	
	var total_aves = modelo_epidemiologico.agentes.size()
	var mortes = modelo_epidemiologico.qtd_mortos
	var prejuizo = modelo_epidemiologico.prejuizo
	var pico = modelo_epidemiologico.dia_pico_infectados
	
	var texto = "--- RELATÓRIO FINAL ---\n"
	texto += "Total de aves: %d\n" % total_aves
	texto += "Total de óbitos: %d\n" % mortes
	texto += "Dia do pico: %d\n" % pico
	texto += "Prejuízo: R$ %.2f\n" % prejuizo
	
	$RelatorioDialog.dialog_text = texto
	$RelatorioDialog.popup_centered()
