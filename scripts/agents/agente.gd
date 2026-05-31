extends Node2D
class_name Agente

@onready var sprite: ColorRect = $Visual

const TAMANHO_AGENTE := 16.0


var id: int = -1
var estado: sir_estados.Estado = sir_estados.Estado.SUSCETIVEL
var velocidade: float = Constants.VELOCIDADE_AGENTE
var direcao: Vector2 = Vector2.ZERO
var tempo_infeccao: float = 0.0

func iniciar_infeccao():
	tempo_infeccao = 0.0

# metodo responsavel por alterar o estado 
func set_estado(novo_estado: sir_estados.Estado) -> void:
	estado = novo_estado
	atualizar_visual()
	

# metodo que muda a cor do agente pelo estado
func atualizar_visual():
	match estado:
		sir_estados.Estado.SUSCETIVEL:
			sprite.color = Constants.COR_SUSCETIVEL
		sir_estados.Estado.INFECTADO:
			sprite.color = Constants.COR_INFECTADO
		sir_estados.Estado.RECUPERADO:
			sprite.color = Constants.COR_RECUPERADO


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
