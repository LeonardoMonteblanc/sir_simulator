extends Node2D
class_name Agente


@onready var sprite: ColorRect = $Visual # representa o quadrado que simula do agente
@onready var raio_visual: Node2D = $RaioVisual # representa o sprite do raio do agente

const TAMANHO_AGENTE := 16.0 # tamanho em pixel do agente

# variaveis iniciais do agente
var id: int = -1 
var estado: sir_estados.Estado = sir_estados.Estado.SUSCETIVEL 
var velocidade: float = Constants.VELOCIDADE_AGENTE 
var direcao: Vector2 = Vector2.ZERO
var tempo_infeccao: float = 0.0

# metodo responsavel por alterar o estado 
func set_estado(novo_estado: sir_estados.Estado) -> void:
	estado = novo_estado 
	atualizar_visual()
	
	if estado == sir_estados.Estado.INFECTADO:
		iniciar_infeccao()
	elif estado == sir_estados.Estado.RECUPERADO:
		tempo_infeccao = 0.0

func iniciar_infeccao():
	tempo_infeccao = 0.0

func inicializar_direcao():
	direcao = Vector2(
		randf_range(-1.0, 1.0),
		randf_range(-1.0,1.0)
	).normalized()


#calculo da distancia
func calcular_distancia(outro) -> float:
	return position.distance_to(outro.position)

# metodo que muda a cor do agente pelo estado
func atualizar_visual():
	match estado:
		sir_estados.Estado.SUSCETIVEL:
			sprite.color = Constants.COR_SUSCETIVEL
		sir_estados.Estado.INFECTADO:
			sprite.color = Constants.COR_INFECTADO
		sir_estados.Estado.RECUPERADO:
			sprite.color = Constants.COR_RECUPERADO

# metodo para detectar as bordas
func detectar_bordas():
	if position.x <= 0:
		position.x = 0
		direcao.x *= -1
	elif position.x >= Constants.LARGURA_AREA:
		position.x = Constants.LARGURA_AREA
		direcao.x *= -1
	
	if position.y <= 0:
		position.y = 0 
		direcao.y *= -1
	
	elif position.y  >= Constants.ALTURA_AREA:
		position.y = Constants.ALTURA_AREA
		direcao.y *= -1

# desenha o raio 
func _draw():
	draw_circle(Vector2.ZERO, Constants.RAIO_CONTAGIO, Color(1,0,0,0.1))


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	queue_redraw()
	
	if direcao == Vector2.ZERO:
		inicializar_direcao()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()
	position += direcao * velocidade * delta
	detectar_bordas()
