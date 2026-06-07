extends Control

# CONSTANTES DE INTERFACE ---------------------------------------------------
const CORES_ESTADOS: Dictionary = {
	0: Color.GREEN, # suscetivel (S)
	1: Color.DARK_ORANGE, # exposto (E)
	2: Color.RED, # infectado (I)
	3: Color.BLUE, # recuperado (R)
	4: Color.BLACK, # morto (D)
}

# REFERÊNCIAS DOS NÓS DA CENA ---------------------------------------------------
@onready var editor_grafos: GraphEdit = $GraphEdit

# VARIÁVEIS DE CONTROLE DA SIMULAÇÃO ---------------------------------------------------
var modelo_epidemiologico: SEIRDModel
var parametros_globais: Dictionary

# INICIALIZAÇÃO DA VIEW ---------------------------------------------------
func _ready():
	parametros_globais = {
		"seed": 32,
		"disease": "Newcastle",
		"num_agents": 20,
		"num_females": 15,
		"vac_coverage": 0.1,
		"egg_price": 0.5,
		"bird_price": 25,
		"layout_galinheiro": "free_range"
	}
	
	var gerador_topologia:= GraphGenerator.new()
	var resultado_grafo: Dictionary = gerador_topologia.generate(parametros_globais["num_agents"], parametros_globais["layout_galinheiro"])
	
	var malha_adjacencia: Dictionary = resultado_grafo["adjacency"]
	var coordenadas_nos: Dictionary = resultado_grafo["positions"]
	
	modelo_epidemiologico = SEIRDModel.new()
	modelo_epidemiologico.initialize(parametros_globais, malha_adjacencia)
	
	_construir_rede_grafica(malha_adjacencia, coordenadas_nos)
	
func _construir_rede_grafica(adj: Dictionary, pos: Dictionary):
	for id_agente in pos.keys():
		var instancia_no_grafico := GraphNode.new()
		
		instancia_no_grafico.name = str(id_agente)
		instancia_no_grafico.title = "Ave " + str(id_agente)
		instancia_no_grafico.position_offset = pos[id_agente]
		instancia_no_grafico.custom_minimum_size = Vector2(100,60)
		
		instancia_no_grafico.set_slot(0, true, 0, Color.WHITE, true, 0, Color.WHITE)
		instancia_no_grafico.self_modulate = CORES_ESTADOS[0]
		
		editor_grafos.add_child(instancia_no_grafico)
	
	for id_origem in adj.keys():
		for aresta in adj[id_origem]:
			var id_destino: int = aresta["neighbor_id"]
			
			if id_origem < id_destino:
				editor_grafos.connect_node(str(id_origem), 0, str(id_destino),0)
	
		
		
