extends Node
class_name RecoveryManager

var simulation_manager

func processar_recuperacao(agentes: Array, delta: float):
	if simulation_manager == null:
		return
	if simulation_manager.doenca_atual == null:
		return

	for agente in agentes:
		if agente.estado != sir_estados.Estado.INFECTADO:
			continue
		
		agente.tempo_infeccao += delta
		
		var tempo_limite = simulation_manager.doenca_atual.duracao_infeccao
		
		if agente.tempo_infeccao >= tempo_limite:
			agente.set_estado(sir_estados.Estado.RECUPERADO)
			agente.tempo_infeccao = 0.0
