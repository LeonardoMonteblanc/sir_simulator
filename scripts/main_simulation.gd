extends Control

@onready var simulation_view = $HBoxContainer/SimulationView
@onready var metrics_view = $HBoxContainer/MetricsView

func _ready():
	if simulation_view.has_signal("passo_concluido"):
		simulation_view.passo_concluido.connect(metrics_view.atualizar_metricas_painel)
		print("sinal conectado")
	else:
		printerr("nao concluido")
		
	if not metrics_view.has_method("atualizar_metricas_painel"):
		printerr("Erro: O nó MetricsView não possui o método 'atualizar_metricas_painel'.")
