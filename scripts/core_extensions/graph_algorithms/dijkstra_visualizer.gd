extends Node

# Visualizador Dijkstra: constroi menor caminho a partir da origem,
# destaca visualmente as arestas do caminho encontrado (pior caso por padrao).
# Consome graph_registry.

const DijkstraRunnerScript = preload("res://scripts/core_extensions/graph_algorithms/dijkstra_runner.gd")

const COR_CAMINHO: Color = Color(0.20, 0.95, 0.30, 1.0)  # verde brilhante para caminho
const COR_DISTANCIA: Color = Color(0.20, 0.45, 0.80, 1.0)  # azul para nos visitados (alcancados)

var _registry: Node = null
var _resultado: Dictionary = {}

func set_registry(reg: Node) -> void:
	_registry = reg

# Calcula Dijkstra a partir de origem e destaca o caminho ate o no mais distante.
func executar(origem: int) -> Dictionary:
	if not is_instance_valid(_registry):
		return {}
	var ids: Array = _registry.get_todos_ids()
	var adj: Dictionary = _registry.get_adjacencia()
	_resultado = DijkstraRunnerScript.executar(adj, origem, ids)
	# destaca caminho do pior caso (ou origem se ela mesma for a mais distante)
	if _resultado.get("pior_caminho", []).size() > 1:
		_destacar_caminho(_resultado["pior_caminho"])
	return _resultado

func get_resultado() -> Dictionary:
	return _resultado

func _destacar_caminho(caminho: Array) -> void:
	if not is_instance_valid(_registry):
		return
	# marca nos do caminho
	for id in caminho:
		_registry.cor_temporaria(int(id), COR_CAMINHO)
	# redesenha arestas do caminho conectando origem ate destino
	_registry.destacar_caminho(caminho, COR_CAMINHO)

func cancelar() -> void:
	if is_instance_valid(_registry):
		_registry.resetar_cores_algoritmo()
