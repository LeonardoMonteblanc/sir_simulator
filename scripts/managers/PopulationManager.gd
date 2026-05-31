extends Node


const CENA_AGENTE = preload("res://scenes/agents/Agente.tscn")

var agentes: Array = []

func criar_agentes():
	for i in range(50):
		var agente = CENA_AGENTE.instantiate()

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
