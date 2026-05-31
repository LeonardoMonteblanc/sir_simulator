extends Node2D
class_name AGraphNode

@onready var visual: ColorRect = $Visual

var agente_id: int
var estado: sir_estados.Estado

func configurar(id: int, estado_inicial: sir_estados.Estado):
	agente_id = id
	estado = estado_inicial
	atualizar_cor()

func atualizar_cor():
	match estado:
		sir_estados.Estado.SUSCETIVEL:
			visual.color = Constants.COR_SUSCETIVEL
		sir_estados.Estado.INFECTADO:
			visual.color = Constants.COR_INFECTADO
		sir_estados.Estado.RECUPERADO:
			visual.color = Constants.COR_RECUPERADO
