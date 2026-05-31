extends  Node2D

@onready var sim = $SimulacaoManager
@onready var pop = $PopulacaoManager
@onready var inf = $InfeccaoManager
@onready var rec = $RecuperacaoManager

func _ready():
	pop.criar_agentes()
	sim.population_manager = pop
	sim.infection_manager = inf
	sim.recovery_manager = rec
	sim.inicializar()
	
