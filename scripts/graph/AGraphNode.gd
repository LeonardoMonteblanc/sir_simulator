extends Node2D
class_name AGraphNode

@onready var visual: TextureRect = $Visual

var agente_id: int
var estado: sir_estados.Estado

func _ready() -> void:
	#visual.custom_minimum_size = Vector2(6, 6)
	#visual.size = Vector2(6, 6)
	visual.position = Vector2(-3, -3)
	visual.stretch_mode = TextureRect.STRETCH_SCALE

func configurar(id: int, estado_inicial: sir_estados.Estado):
	agente_id = id
	estado = estado_inicial
	atualizar_cor()

func atualizar_cor():
	match estado:
		sir_estados.Estado.SUSCETIVEL:
			visual.modulate = Constants.COR_SUSCETIVEL
		sir_estados.Estado.INFECTADO:
			visual.modulate = Constants.COR_INFECTADO
		sir_estados.Estado.RECUPERADO:
			visual.modulate = Constants.COR_RECUPERADO
