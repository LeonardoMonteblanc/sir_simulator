extends Control

const CORES_ESTADOS: Dictionary = {
	SEIRDModel.Estado.S: Color(0.18, 0.54, 0.31),
	SEIRDModel.Estado.E: Color(0.88, 0.56, 0.13),
	SEIRDModel.Estado.I: Color(0.75, 0.19, 0.13, 1.0),
	SEIRDModel.Estado.R: Color(0.13, 0.33, 0.67),
	SEIRDModel.Estado.D: Color(0.33, 0.33, 0.33),
}

@onready var editor_grafos: GraphEdit = $GraphContainer/GraphEdit
var _autosim: Node = null
var _graph_registry: Node = null

signal passo_concluido(dados_dia: Dictionary)
signal surto_encerrado

var modelo_epidemiologico: SEIRDModel

func _ready() -> void:
	limpar_simulacao()

func inicializar_com_config(config: Dictionary) -> void:
	limpar_simulacao()
	
	var gerador_redes := GraphGenerator.new()
	var num_agentes = config.get("num_agents", 10)
	var layout = config.get("layout", "solto")
	var disease = config.get("disease", "Newcastle")
	
	var resultado_grafo: Dictionary = gerador_redes.generate(num_agentes, layout)
	
	var malha_adjacencia: Dictionary = resultado_grafo.get("adjacency", {})
	var coordenadas_nos: Dictionary = resultado_grafo.get("positions", {})
	var params = {
		"num_agents": num_agentes,
		"disease": disease
	}
	modelo_epidemiologico = SEIRDModel.new()
	modelo_epidemiologico.initialize(params, malha_adjacencia)
	
	_construir_rede_grafica(malha_adjacencia, coordenadas_nos)


func _construir_rede_grafica(adj: Dictionary, pos: Dictionary) -> void:
	limpar_simulacao()

	var lista_agentes: Array = modelo_epidemiologico.agentes
	var nos_por_id: Dictionary = {}

	for agente_obj in lista_agentes:
		var no_agente := GraphNode.new()
		var id_str: String = str(agente_obj.id)
		no_agente.name = id_str
		no_agente.title = "Ave %d" % agente_obj.id

		var pos_fallback: Vector2 = Vector2((agente_obj.id % 5) * 150, (agente_obj.id / 5) * 100)
		no_agente.position_offset = pos.get(agente_obj.id, pos_fallback)
		no_agente.custom_minimum_size = Vector2(80, 50)
		var cor_inicial: Color = CORES_ESTADOS.get(agente_obj.estado, Color.WHITE)
		no_agente.self_modulate = cor_inicial

		# slot interno (grafo precisa de filhos para criar ports)
		var slot_control := Control.new()
		slot_control.custom_minimum_size = Vector2(80, 40)
		no_agente.add_child(slot_control)

		editor_grafos.add_child(no_agente)
		# configura port esquerda e direita no indice 0
		no_agente.set_slot(0, true, 0, Color.WHITE, true, 1, Color.WHITE)

		nos_por_id[agente_obj.id] = no_agente
		# registra no registry (se anexado)
		if is_instance_valid(_graph_registry) and _graph_registry.has_method("registrar"):
			_graph_registry.registrar(agente_obj.id, no_agente, cor_inicial)

	# process_frame para o editor preparar os slots antes de conectar
	await get_tree().process_frame

	# desenha cada aresta uma unica vez (id_o < id_d)
	for chave_origem in adj.keys():
		var id_o: int = chave_origem
		for aresta in adj[chave_origem]:
			var id_d: int = aresta.get("neighbor_id", -1)
			if id_o >= id_d:
				continue
			if not nos_por_id.has(id_o) or not nos_por_id.has(id_d):
				continue
			if not editor_grafos.is_node_connected(str(id_o), 0, str(id_d), 0):
				editor_grafos.connect_node(str(id_o), 0, str(id_d), 0)

	editor_grafos.arrange_nodes()

func _on_zoom_in() -> void:
	if not is_instance_valid(editor_grafos):
		return
	editor_grafos.zoom = min(editor_grafos.zoom * 1.2, 4.0)

func _on_zoom_out() -> void:
	if not is_instance_valid(editor_grafos):
		return
	editor_grafos.zoom = max(editor_grafos.zoom * 0.8, 0.25)

func _on_reset_view() -> void:
	if not is_instance_valid(editor_grafos):
		return
	editor_grafos.zoom = 1.0
	editor_grafos.offset = Vector2.ZERO


# Injeta controller de auto-sim (AutoSimulationController). Idempotente.
func injetar_autosim(controller: Node) -> void:
	if _autosim == controller:
		return
	# desconecta anterior
	if is_instance_valid(_autosim) and _autosim.has_signal("tick"):
		if _autosim.tick.is_connected(_on_autosim_tick):
			_autosim.tick.disconnect(_on_autosim_tick)
	_autosim = controller
	if is_instance_valid(_autosim):
		if _autosim.has_signal("tick") and not _autosim.tick.is_connected(_on_autosim_tick):
			_autosim.tick.connect(_on_autosim_tick)

func _on_autosim_tick() -> void:
	if not is_instance_valid(modelo_epidemiologico):
		return

	var dados_passo_atual: Dictionary = modelo_epidemiologico.step()
	# atualiza cores visualmente ANTES de emitir o sinal, para o HUD ver o estado novo
	for agente_objeto in modelo_epidemiologico.agentes:
		var no_alvo: GraphNode = editor_grafos.get_node_or_null(str(agente_objeto.id)) as GraphNode
		if no_alvo != null:
			no_alvo.self_modulate = CORES_ESTADOS.get(agente_objeto.estado, Color.WHITE)

	passo_concluido.emit(dados_passo_atual)

	if modelo_epidemiologico.is_outbreak_over():
		surto_encerrado.emit()
		# encerra simulacao automatica se estiver ativa
		stop_autosim()

# Hooks publicos de play/pause/stop consumidos pelo control_panel.
func start_autosim(speed_seconds: float = 1.0) -> void:
	if not is_instance_valid(_autosim):
		return
	_autosim.call("start", speed_seconds)

func pause_autosim() -> void:
	if not is_instance_valid(_autosim):
		return
	_autosim.call("pause_simulation")

func resume_autosim() -> void:
	if not is_instance_valid(_autosim):
		return
	_autosim.call("resume")

func stop_autosim() -> void:
	if not is_instance_valid(_autosim):
		return
	_autosim.call("stop")

func set_speed_autosim(speed_seconds: float) -> void:
	if not is_instance_valid(_autosim):
		return
	_autosim.call("set_speed", speed_seconds)

func has_autosim() -> bool:
	return is_instance_valid(_autosim)


func renderizar_estado_atual() -> void:
	if not is_instance_valid(modelo_epidemiologico):
		return
	for agente in modelo_epidemiologico.agentes:
		var no_agente: GraphNode = editor_grafos.get_node_or_null(str(agente.id)) as GraphNode
		if no_agente != null:
			no_agente.self_modulate = CORES_ESTADOS.get(agente.estado, Color.WHITE)
	# evita re-aplicar adjacencia vazia quando o modelo ainda nao foi inicializado
	if modelo_epidemiologico.adjacencia == null or modelo_epidemiologico.adjacencia.is_empty():
		return
	atualizar_adjacencia_visual(modelo_epidemiologico.adjacencia)

func atualizar_adjacencia_visual(nova_adj: Dictionary) -> void:
	if not is_instance_valid(editor_grafos):
		return
	editor_grafos.clear_connections()
	for id_origem in nova_adj.keys():
		for aresta in nova_adj[id_origem]:
			var id_destino: int = aresta.get("neighbor_id", -1)
			if id_destino < 0:
				continue
			editor_grafos.connect_node(str(id_origem), 0, str(id_destino), 0)

func limpar_simulacao() -> void:
	if not is_instance_valid(editor_grafos):
		return
	editor_grafos.clear_connections()
	for no_filho in editor_grafos.get_children():
		if no_filho is GraphNode:
			editor_grafos.remove_child(no_filho)
			no_filho.queue_free()
	editor_grafos.queue_redraw()
	editor_grafos.queue_redraw()
