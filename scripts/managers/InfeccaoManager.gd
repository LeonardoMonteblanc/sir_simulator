extends Node

var simulation_manager

func processar_infeccao():
	var agentes = simulation_manager.obter_agentes()
	
	for a in agentes:
		if a.estado != sir_estados.Estado.INFECTADO:
			continue
			
		for b in agentes:
			if b.estado != sir_estados.Estado.SUSCETIVEL:
				continue
				
			if validar_raio(a,b):
				tentar_infectar(b)

func validar_raio(a,b)-> bool:
	return a.calcular_distancia(b) <= Constants.RAIO_CONTAGIO

func tentar_infectar(agente):
	var beta = simulation_manager.doenca_atual.taxa_transmissao
	var sorteio = randf()
	
	if sorteio < beta:
		agente.set_estado(sir_estados.Estado.INFECTADO)
		agente.iniciar_infeccao()
