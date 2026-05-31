extends  Node2D

var agente = preload("res://scenes/agents/Agente.tscn").instantiate()


func _ready():
	$PopulationManager.criar_agentes()
	var covid = Doenca.new(
		"COVID",
		0.35,
		8.0
	)

	print(covid.nome)
	print(covid.taxa_transmissao)
	print(covid.duracao_infeccao)
	
	add_child(agente)
	
func _input(event):
	if event.is_action_pressed("ui_accept"):
		agente.set_estado(sir_estados.Estado.SUSCETIVEL)
	if event.is_action_pressed("ui_left"):
		agente.set_estado(sir_estados.Estado.INFECTADO)
	if event.is_action_pressed("ui_right"):
		agente.set_estado(sir_estados.Estado.RECUPERADO)
		
