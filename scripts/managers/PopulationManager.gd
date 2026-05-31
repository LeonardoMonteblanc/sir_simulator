extends Node


const CENA_AGENTE = preload("res://scenes/agents/Agente.tscn")

var agentes: Array = []

func criar_agentes():
	for i in range(50):
		var agente = CENA_AGENTE.instantiate()
	
		var margem = Agente.TAMANHO_AGENTE / 2.0
		agente.position = Vector2(
			randi_range(margem, Constants.LARGURA_AREA - margem),
			randi_range(margem, Constants.ALTURA_AREA - margem)
		)
		
		agentes.append(agente)
		get_tree().current_scene.add_child(agente)


# manipulacao da array com os agentes
func adicionar_agente(agente):
	agentes.append(agente)

func remover_agente(agente):
	agentes.erase(agente)

func obter_agentes() -> Array:
	return agentes

func quantidade_agentes() -> int:
	return agentes.size()
