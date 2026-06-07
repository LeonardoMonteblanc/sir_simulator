extends Control

# CONSTANTES DE INTERFACE ---------------------------------------------------
const CORES_ESTADOS: Dictionary = {
	0: Color.GREEN, # suscetivel (S)
	1: Color.YELLOW, # exposto (E)
	2: Color.RED, # infectado (I)
	3: Color.BLUE, # recuperado (R)
	4: Color.BLACK, # morto (D)
}

# REFERÊNCIAS DOS NÓS DA CENA ---------------------------------------------------
@onready var editor_grafos: GraphEdit = $GraphEdit

# SINAIS CUSTOMIZADOS ---------------------------------------------------
signal passo_concluido(dados_dia: Dictionary)

# VARIÁVEIS DE CONTROLE DA SIMULAÇÃO ---------------------------------------------------
var modelo_epidemiologico: SEIRDModel
var parametros_globais: Dictionary = {"num_agents": 20}

# INICIALIZAÇÃO DA VIEW ---------------------------------------------------
func _ready():
	$BtnPasso.pressed.connect(_on_step_pressed)
	if parametros_globais.size() <=1:
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
		
	limpar_simulacao()
	
	
	var gerador_redes:= GraphGenerator.new()
	var resultado_grafo: Dictionary = gerador_redes.generate(parametros_globais["num_agents"], parametros_globais["layout_galinheiro"])
	
	var malha_adjacencia: Dictionary = resultado_grafo["adjacency"]
	var coordenadas_nos: Dictionary = resultado_grafo["positions"]
	
	if not modelo_epidemiologico:
		modelo_epidemiologico = SEIRDModel.new()
		modelo_epidemiologico.initialize(parametros_globais, malha_adjacencia)
	
	_construir_rede_grafica(malha_adjacencia, coordenadas_nos)
	
func _construir_rede_grafica(adj: Dictionary, pos: Dictionary):
	var lista_agentes = modelo_epidemiologico.agentes
	for agente_objeto in lista_agentes:
		var instancia_no_grafico := GraphNode.new()
		instancia_no_grafico.name = str(agente_objeto.id)
		instancia_no_grafico.title = "Ave " + str(agente_objeto.id)
		
		if pos.has(agente_objeto.id):
			instancia_no_grafico.position_offset = pos[agente_objeto.id]
		
		instancia_no_grafico.set_slot(0, true, 0, Color.WHITE, true, 0, Color.WHITE)
		instancia_no_grafico.custom_minimum_size = Vector2(100,60)
		instancia_no_grafico.self_modulate = CORES_ESTADOS[agente_objeto.estado]
	
		editor_grafos.add_child(instancia_no_grafico)
	
	await get_tree().process_frame
	
	for id_origem in adj.keys():
		var id_o = int(id_origem)
		for aresta in adj[id_origem]:
			var id_d = aresta["neighbor_id"]
			
			if editor_grafos.has_node(str(id_o)) and editor_grafos.has_node(str(id_d)):
				editor_grafos.connect_node(str(id_o), 0, str(id_d), 0)

# GATILHOS DE ATUALIZAÇÃO TEMPORAL ---------------------------------------------------
func _on_step_pressed():
	if not is_instance_valid(modelo_epidemiologico):
		return
	
	var dados_passo_atual: Dictionary = modelo_epidemiologico.step()
	var lista_agentes: Array = dados_passo_atual["agentes"]
	
	for agente_objeto in lista_agentes:
		var no_alvo := editor_grafos.get_node_or_null(str(agente_objeto.id)) as GraphNode
				
		if no_alvo:
			no_alvo.self_modulate = CORES_ESTADOS[agente_objeto.estado]
	
	var dados_interface = {
		"suscetiveis": dados_passo_atual.get("suscetiveis", 0),
		"infectados": dados_passo_atual.get("infectados", 0),
		"prejuizo": dados_passo_atual.get("prejuizo", 0.0)
	}
	
	passo_concluido.emit(dados_interface)

# GERENCIAMENTO E LIMPEZA DE MEMÓRIA ---------------------------------------------------
func limpar_simulacao():
	var esta_no_terminal: bool = true
	
	for argumento_sistema in OS.get_cmdline_args():
		if "teste.gd" in OS.get_cmdline_args():
			esta_no_terminal = true
	
	if esta_no_terminal and not is_inside_tree():
		return
	
	if is_instance_valid(editor_grafos):
		editor_grafos.clear_connections()
		
		var lista_limpeza_imediata: Array = []
		for no_filho in editor_grafos.get_children():
			if no_filho is GraphNode:
				lista_limpeza_imediata.append(no_filho)

		while lista_limpeza_imediata.size() > 0:
			var no_temporario = lista_limpeza_imediata.pop_back()
			
			if is_instance_valid(no_temporario):
				if no_temporario.get_parent() == editor_grafos:
					editor_grafos.remove_child(no_temporario)
				no_temporario.free()
