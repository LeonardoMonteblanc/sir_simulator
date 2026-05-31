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

			if validar_raio(a, b):
				tentar_infectar(b, a)

func validar_raio(a,b)-> bool:
	return a.calcular_distancia(b) <= Constants.RAIO_CONTAGIO

func tentar_infectar(alvo, fonte):
	var beta = simulation_manager.doenca_atual.taxa_transmissao
	var sorteio = randf()

	if sorteio < beta:
		alvo.set_estado(sir_estados.Estado.INFECTADO)
		alvo.iniciar_infeccao()

		# REGISTRO DO EVENTO (ESSENCIAL PARA O GRAFO)
		simulation_manager.infectados_origem[alvo.id] = fonte.id
