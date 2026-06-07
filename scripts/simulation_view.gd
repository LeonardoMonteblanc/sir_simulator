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
	var lista_entidades_ativas: Array = modelo_epidemiologico.get_agents() if modelo_epidemiologico.has_method("get_agents") else modelo_epidemiologico.agentes
	for agente_objeto in lista_entidades_ativas:
		var id_chave: int = agente_objeto.id
		var estado: int = agente_objeto.estado
		
		var instancia_no_grafico := GraphNode.new()
		instancia_no_grafico.name = str(id_chave)
		instancia_no_grafico.title = "Ave " + str(id_chave)
		
		if pos.has(id_chave):
			instancia_no_grafico.position_offset = pos[id_chave]

		instancia_no_grafico.custom_minimum_size = Vector2(100,60)
		instancia_no_grafico.set_slot(0, true, 0, Color.WHITE, true, 0, Color.WHITE)
		instancia_no_grafico.self_modulate = CORES_ESTADOS[estado]
	
		editor_grafos.add_child(instancia_no_grafico)
	
	for id_origem in adj.keys():
		var origem_int: int = int(id_origem) if id_origem is String else id_origem
		
		if not editor_grafos.has_node((str(id_origem))):
			continue
		
		for aresta in adj[id_origem]:
			var id_destino: int = aresta["neighbor_id"]
			
			if editor_grafos.has_node(str(id_destino)) and origem_int < id_destino:
				editor_grafos.connect_node(str(id_origem), 0, str(id_destino),0)

# GATILHOS DE ATUALIZAÇÃO TEMPORAL ---------------------------------------------------
func _on_step_pressed():
	var dados_passo_atual: Dictionary= modelo_epidemiologico.step()
	var lista_agentes: Array = dados_passo_atual["agentes"]
	
	for agente_objeto in lista_agentes:
		var id_agente: int = agente_objeto.id
		var estado_atual: int = agente_objeto.estado
		
		var no_alvo := editor_grafos.get_node(str(id_agente)) as GraphNode
		
		if no_alvo:
			no_alvo.self_modulate = CORES_ESTADOS[estado_atual]
	
	passo_concluido.emit(dados_passo_atual)

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
