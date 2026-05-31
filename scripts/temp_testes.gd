extends  Node2D

@onready var sim = $SimulacaoManager
@onready var pop = $PopulacaoManager
@onready var inf = $InfeccaoManager
@onready var rec = $RecuperacaoManager
@onready var graf = $Window/GraphView/GrafoManager

func _ready():
	pop.criar_agentes()
	
	sim.graph_manager = graf
	
	sim.population_manager = pop
	sim.infection_manager = inf
	sim.recovery_manager = rec
	sim.doenca_dados = DoencaDatabase.new()
	sim.set_doenca("COVID")
	sim.inicializar()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		sim.trocar_doenca("DENGUE")
