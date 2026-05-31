extends Node

var population_manager
var infection_manager
var recovery_manager

var doenca_dados: DoencaDatabase
var doenca_atual: Doenca

var pronto := false

func obter_agentes():
	return population_manager.obter_agentes()

func _ready():
	pass

func set_doenca(nome:String):
	if doenca_dados == null:
		return
		
	var d = doenca_dados.get_doenca(nome)
	if d == null:
		return
	doenca_atual = d

func inicializar():
	if doenca_dados == null:
		return false
		
	if infection_manager == null or recovery_manager == null:
		return false
		
	doenca_atual = doenca_dados.get_doenca("COVID")
	if doenca_atual == null:
		return false
		
	infection_manager.simulation_manager = self
	recovery_manager.simulation_manager = self
	
	pronto = true
	return true

func _process(delta):
	if not pronto:
		return
	
	if doenca_atual == null:
		return
	
	infection_manager.processar_infeccao()
	recovery_manager.processar_recuperacao(obter_agentes(), delta)
