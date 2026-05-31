extends Node
const CENA_AGENTE = preload("res://scenes/agents/Agente.tscn")

var agentes: Array = []
var proximo_id: int = 0
var qtd_inicial_infectado: int = Constants.QTD_INFECTADOS_INICIAL

func criar_agentes():
	for i in range(Constants.QTD_AGENTES):
		var agente = CENA_AGENTE.instantiate()
		agente.inicializar_direcao()
		
		agente.id = gerar_id_unico()
		var margem = Agente.TAMANHO_AGENTE / 2.0
		agente.position = Vector2(
			randi_range(margem, Constants.LARGURA_AREA - margem),
			randi_range(margem, Constants.ALTURA_AREA - margem)
		)
		
		agentes.append(agente)
		get_tree().current_scene.add_child(agente)
		print(agente.id)
	
	set_infectados_inicial()

func set_infectados_inicial():
	var indices = []
	
	for i in range(Constants.QTD_AGENTES):
		indices.append(i)
	
	indices.shuffle()
	
	for j in range(qtd_inicial_infectado):
		var agente = agentes[indices[j]]
		agente.set_estado(sir_estados.Estado.INFECTADO)
		agente.iniciar_infeccao()

func gerar_id_unico() -> int:
	proximo_id += 1
	return proximo_id
	

# manipulacao da array com os agentes
func adicionar_agente(agente):
	agentes.append(agente)

func remover_agente(agente):
	agentes.erase(agente)

func obter_agentes() -> Array:
	return agentes

func quantidade_agentes() -> int:
	return agentes.size()
