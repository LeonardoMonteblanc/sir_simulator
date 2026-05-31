extends Node

var agentes: Array = []

# manipulacao da array com os agentes
func adicionar_agente(agente):
	agentes.append(agente)

func remover_agente(agente):
	agentes.erase(agente)

func obter_agentes() -> Array:
	return agentes

func quantidade_agentes() -> int:
	return agentes.size()
