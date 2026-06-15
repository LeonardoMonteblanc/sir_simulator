extends Node

# Registry de nos visuais do grafo + helpers para algoritmos.
# Feature em core_extensions/graph_algorithms/. A view (simulation_view.gd)
# NAO conhece algoritmos; ela apenas expoe referencias ao registry.
# Algoritmos (BFS, DFS, Dijkstra) consomem esta API para iterar/visualizar.
#
# API publica:
#   registrar(id, node)           : quando a view cria um no
#   limpar()                      : limpa registry
#   get_node_by_id(id)            : GraphNode ou null
#   get_todos_ids()               : Array[int]
#   get_adjacencia()              : copia do dicionario de adjacencia
#   set_adjacencia(dict)          : atualiza adjacencia (apos isolamento)
#   resetar_cores_base(cores_seird) : restaura cor de estado SEIRD em todos os nos
#   cor_temporaria(id, color, dur_s) : marca cor temporaria (algoritmo). dur<=0 = permanente ate reset
#   resetar_cores_algoritmo()     : limpa marcas de algoritmo

const DEFAULT_ALGO_COLOR: Color = Color(0.8, 0.8, 0.0, 1.0)  # amarelo (visivel)

var _nodes: Dictionary = {}      # id -> GraphNode
var _estado_base: Dictionary = {} # id -> Color (cor SEIRD original)
var _marcacoes: Dictionary = {}  # id -> {"color": Color, "dur": float}
var _cores_seird: Dictionary = {}
var _adj: Dictionary = {}
var _no_grafo_edit: GraphEdit = null

func set_grafo_edit(g: GraphEdit) -> void:
	_no_grafo_edit = g

func set_cores_seird(cores: Dictionary) -> void:
	_cores_seird = cores

func registrar(id: int, node: GraphNode, cor_base: Color) -> void:
	_nodes[id] = node
	_estado_base[id] = cor_base

func limpar() -> void:
	_nodes.clear()
	_estado_base.clear()
	_marcacoes.clear()
	_adj.clear()

func get_node_by_id(id: int) -> GraphNode:
	if not _nodes.has(id):
		return null
	var n = _nodes[id]
	if not is_instance_valid(n):
		return null
	return n

func get_todos_ids() -> Array:
	var ids: Array = []
	for k in _nodes.keys():
		ids.append(int(k))
	ids.sort()
	return ids

func get_adjacencia() -> Dictionary:
	var copia: Dictionary = {}
	for k in _adj.keys():
		copia[k] = _adj[k].duplicate()
	return copia

func set_adjacencia(dict: Dictionary) -> void:
	_adj = dict.duplicate(true)

# Restaura a cor original SEIRD em todos os nos registrados.
func resetar_cores_base() -> void:
	for id in _nodes.keys():
		var n: GraphNode = get_node_by_id(id)
		if n != null and _estado_base.has(id):
			n.self_modulate = _estado_base[id]
	_marcacoes.clear()

# Aplica uma cor temporaria a um no. dur<=0 = permanente ate reset_explicito
func cor_temporaria(id: int, color: Color) -> void:
	var n: GraphNode = get_node_by_id(id)
	if n == null:
		return
	n.self_modulate = color
	_marcacoes[id] = color

# Limpa apenas marcacoes de algoritmo, restaura cor SEIRD onde estava marcada.
func resetar_cores_algoritmo() -> void:
	for id in _marcacoes.keys():
		var n: GraphNode = get_node_by_id(id)
		if n != null and _estado_base.has(id):
			n.self_modulate = _estado_base[id]
	_marcacoes.clear()

# Destaca arestas (connections) entre dois nos. Usado por Dijkstra para
# mostrar o caminho encontrado.
func destacar_caminho(ids: Array, color: Color) -> void:
	if not is_instance_valid(_no_grafo_edit):
		return
	_no_grafo_edit.clear_connections()
	for i in range(ids.size() - 1):
		_no_grafo_edit.connect_node(str(ids[i]), 0, str(ids[i+1]), 0)
