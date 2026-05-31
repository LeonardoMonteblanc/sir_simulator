extends Node

var agentes: Array = []
var simulation_manager

func registrar_agentes(lista_agentes: Array):
	agentes = lista_agentes

func processar_infeccao():
	for i in range(agentes.size()):
		var a = agentes[i]
		
		if a.estado != sir_estados.Estado.INFECTADO:
			continue
		
		for j in range(agentes.size()):
			var b = agentes[j]
			
			if b.estado != sir_estados.Estado.SUSCETIVEL:
				continue
			
			if a.calcular_distancia(b) <= Constants.RAIO_CONTAGIO:
				tentar_infectar(b)


func tentar_infectar(agente):
	var beta = simulation_manager.doenca_atual.taxa_transmissao
	
	if randf() < beta:
		agente.set_estado(sir_estados.Estado.INFECTADO)
		agente.iniciar_infeccao()
		
	
