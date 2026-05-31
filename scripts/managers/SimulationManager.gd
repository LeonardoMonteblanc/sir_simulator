extends Node

var population_manager
var infection_manager
var recovery_manager

var doenca_atual: Doenca

func _ready():
	doenca_atual = Doenca.new("COVID", 0.3, 8.0)

func inicializar():
	var agentes = population_manager.obter_agentes()

	infection_manager.simulation_manager = self
	recovery_manager.simulation_manager = self

	infection_manager.registrar_agentes(agentes)

func _process(delta):
	infection_manager.processar_infeccao()
	recovery_manager.processar_recuperacao(infection_manager.agentes, delta)
