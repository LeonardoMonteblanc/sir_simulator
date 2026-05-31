extends Node2D
class_name Agente

var id: int = -1
var estado: sir_estados.Estado = sir_estados.Estado.SUSCETIVEL
var velocidade: float = Constants.VELOCIDADE_AGENTE
var direcao: Vector2 = Vector2.ZERO
var tempo_infeccao: float = 0.0


# metodo responsavel por alterar o estado 
func set_estado(novo_estado: sir_estados.Estado) -> void:
	estado = novo_estado
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
