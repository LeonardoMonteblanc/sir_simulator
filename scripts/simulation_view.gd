extends Control

# CONSTANTES DE INTERFACE ---------------------------------------------------
const CORES_ESTADOS: Dictionary = {
	SEIRDModel.Estado.S: Color(0.18,0.54,0.31),
	SEIRDModel.Estado.E: Color(0.88,0.56,0.13),
	SEIRDModel.Estado.I: Color(0.75, 0.19, 0.13, 1.0),
	SEIRDModel.Estado.R: Color(0.13,0.33,0.67),
	SEIRDModel.Estado.D: Color(0.33,0.33,0.33),
}

# REFERÊNCIAS DOS NÓS DA CENA ---------------------------------------------------
@onready var editor_grafos: GraphEdit = $GraphEdit
@onready var botao_passo: Button = $BtnPasso

# SINAIS CUSTOMIZADOS ---------------------------------------------------
signal passo_concluido(dados_dia: Dictionary)
signal surto_encerrado

# VARIÁVEIS DE CONTROLE DA SIMULAÇÃO ---------------------------------------------------
var modelo_epidemiologico: SEIRDModel
var parametros_globais: Dictionary = {}

# INICIALIZAÇÃO DA VIEW ---------------------------------------------------
func _ready():
	botao_passo.pressed.connect(_on_step_pressed)
	parametros_globais = SimConfig.params
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
	limpar_simulacao()
	
	var lista_agentes = modelo_epidemiologico.agentes
	var nos_por_id = {}
	
	# Itera sobre cada agente para criar seu nó no gráfico
	for agente_obj in lista_agentes:
		# 1. Cria o GraphNode
		var no_agente := GraphNode.new()
		var id_str = str(agente_obj.id)
		no_agente.name = id_str
		no_agente.title = "Ave " + id_str
		no_agente.position_offset = pos.get(agente_obj.id, Vector2((agente_obj.id % 5) * 150, (agente_obj.id / 5) * 100))
		no_agente.custom_minimum_size = Vector2(80, 50)
		no_agente.self_modulate = CORES_ESTADOS.get(agente_obj.estado, Color.WHITE)
		
		# 2. Adiciona um nó filho 'Control' para criar o slot (índice 0)
		#    Este 'Control' pode ser um simples 'Control' ou 'MarginContainer', etc.
		var slot_control = Control.new()
		slot_control.custom_minimum_size = Vector2(80, 40) # Define altura do slot
		no_agente.add_child(slot_control)
		
		# 3. Adiciona o GraphNode ao GraphEdit
		editor_grafos.add_child(no_agente)
		
		# 4. Configura o slot no índice 0, que corresponde ao 'Control' recem-adicionado
		#    Parâmetros: (slot_index, enable_left, type_left, color_left, enable_right, type_right, color_right)
		no_agente.set_slot(0, true, 0, Color.WHITE, true, 1, Color.WHITE)
		
		# Armazena a referência
		nos_por_id[agente_obj.id] = no_agente
	
	# Aguarda um frame para que todos os nós sejam processados pelo engine
	await get_tree().process_frame
	
	for chave_origem in adj.keys():
		var id_o = chave_origem
		for aresta in adj[chave_origem]:
			var id_d = aresta["neighbor_id"]
			
			if id_o < id_d:
				var node_o = nos_por_id.get(id_o)
				var node_d = nos_por_id.get(id_d)
				if node_o and node_d:
					if node_o.get_output_port_count() > 0 and node_d.get_input_port_count() > 0:
						if not editor_grafos.is_node_connected(str(id_o), 0, str(id_d), 0):
							editor_grafos.connect_node(str(id_o), 0, str(id_d), 0)
	editor_grafos.arrange_nodes()
# GATILHOS DE ATUALIZAÇÃO TEMPORAL ---------------------------------------------------
func _on_step_pressed():
	if not is_instance_valid(modelo_epidemiologico):
		return
	
	var dados_passo_atual: Dictionary = modelo_epidemiologico.step()
	var lista_agentes: Array = modelo_epidemiologico.agentes
	
	for agente_objeto in lista_agentes:
		var no_alvo := editor_grafos.get_node_or_null(str(agente_objeto.id)) as GraphNode
				
		if no_alvo:
			no_alvo.self_modulate = CORES_ESTADOS[agente_objeto.estado]
	passo_concluido.emit(dados_passo_atual)
	
	if modelo_epidemiologico._check_outbreak_over():
		botao_passo.disabled = true
		surto_encerrado.emit()

func renderizar_estado_atual():
	for agente in modelo_epidemiologico.agentes:
		var no_agente := editor_grafos.get_node_or_null(str(agente.id)) as GraphNode
		
		if no_agente:
			no_agente.self_modulate = CORES_ESTADOS[agente.estado]

func atualizar_adjacencia_visual(nova_adj: Dictionary):
	editor_grafos.clear_connections()
	for id_origem in nova_adj.keys():
		for aresta in nova_adj[id_origem]:
			editor_grafos.connect_node(str(id_origem), 0, str(aresta["neighbor_id"]), 0)

# GERENCIAMENTO E LIMPEZA DE MEMÓRIA ---------------------------------------------------
func limpar_simulacao():
	editor_grafos.clear_connections()
	for no_filho in editor_grafos.get_children():
		if no_filho is GraphNode:
			editor_grafos.remove_child(no_filho)
			no_filho.free()
	editor_grafos.queue_redraw()
