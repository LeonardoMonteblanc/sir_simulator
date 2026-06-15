extends Node

# Visualizador BFS: aplica ao registry a cor por nivel (onda de propagacao).
# Core extensions: nao toca no core. Consome graph_registry.

const COR_POR_NIVEL: Array[Color] = [
	Color(0.95, 0.85, 0.10), # nivel 0 - amarelo
	Color(0.90, 0.45, 0.05), # nivel 1 - laranja
	Color(0.85, 0.20, 0.05), # nivel 2 - vermelho
	Color(0.70, 0.10, 0.30), # nivel 3 - roxo
	Color(0.40, 0.20, 0.70), # nivel 4 - azul escuro
	Color(0.20, 0.45, 0.80), # nivel 5 - azul
	Color(0.10, 0.65, 0.70), # nivel 6 - ciano
]

var _registry: Node = null
var _step_atual: int = 0
var _bfs_result: Dictionary = {}
var _nivel_por_id: Dictionary = {}
var _rodando: bool = false

func _ready() -> void:
	set_process(false)

func set_registry(reg: Node) -> void:
	_registry = reg

func is_running() -> bool:
	return _rodando

# Prepara o BFS a partir de um no. Nao inicia a animacao.
func preparar(origem: int) -> bool:
	if not is_instance_valid(_registry):
		return false
	var ids: Array = _registry.get_todos_ids()
	if ids.is_empty():
		return false
	if not ids.has(origem):
		return false
	var adj: Dictionary = _registry.get_adjacencia()
	_bfs_result = BFSRunner.executar(adj, origem, ids)
	_nivel_por_id = _bfs_result.get("niveis", {})
	# limpa qualquer marcacao anterior
	_registry.resetar_cores_algoritmo()
	_step_atual = 0
	_rodando = true
	return true

# Avanca um nivel da animacao. Retorna false quando terminou.
func avancar() -> bool:
	if not _rodando:
		return false
	if not is_instance_valid(_registry):
		_rodando = false
		return false
	var grupos: Dictionary = BFSRunner.por_nivel(_bfs_result)
	var ids: Array = grupos.get(_step_atual, [])
	if ids.is_empty():
		_rodando = false
		return false
	var cor: Color = COR_POR_NIVEL[_step_atual % COR_POR_NIVEL.size()]
	for id in ids:
		_registry.cor_temporaria(int(id), cor)
	_step_atual += 1
	return true

func cancelar() -> void:
	_rodando = false
	if is_instance_valid(_registry):
		_registry.resetar_cores_algoritmo()
