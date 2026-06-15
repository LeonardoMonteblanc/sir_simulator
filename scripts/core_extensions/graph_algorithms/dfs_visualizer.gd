extends Node

# Visualizador DFS: marca nos na ordem em que foram visitados (cor por profundidade).
# Constroi arvore DFS. Permite consultar o caminho ate um destino.

const COR_VISITA: Color = Color(0.30, 0.85, 0.95, 1.0)  # ciano claro para "fronteira"
const COR_BACKTRACK: Color = Color(0.75, 0.40, 0.10, 1.0)  # laranja escuro (nao usado)
const COR_CAMINHO: Color = Color(0.95, 0.85, 0.10, 1.0)  # amarelo para caminho destacado

var _registry: Node = null
var _dfs_result: Dictionary = {}
var _ordem: Array = []
var _idx: int = 0
var _rodando: bool = false

func set_registry(reg: Node) -> void:
	_registry = reg

func is_running() -> bool:
	return _rodando

# Inicia DFS a partir de origem. Pronto para ser avancado passo a passo.
func preparar(origem: int) -> bool:
	if not is_instance_valid(_registry):
		return false
	var ids: Array = _registry.get_todos_ids()
	if ids.is_empty():
		return false
	if not ids.has(origem):
		return false
	var adj: Dictionary = _registry.get_adjacencia()
	_dfs_result = DFSRunner.executar(adj, origem, ids)
	_ordem = _dfs_result.get("ordem_visita", [])
	_idx = 0
	_rodando = true
	_registry.resetar_cores_algoritmo()
	return true

# Avanca um no na visita. Retorna false quando terminou.
func avancar() -> bool:
	if not _rodando:
		return false
	if _idx >= _ordem.size():
		_rodando = false
		return false
	var id: int = int(_ordem[_idx])
	_registry.cor_temporaria(id, COR_VISITA)
	_idx += 1
	return true

# Destaca caminho da origem ate destino (apos executar DFS)
func destacar_caminho(destino: int) -> bool:
	if not is_instance_valid(_registry) or _dfs_result.is_empty():
		return false
	var arvore: Dictionary = _dfs_result.get("arvore", {})
	var caminho: Array = DFSRunner.caminho_para(arvore, destino)
	if caminho.is_empty():
		return false
	for id in caminho:
		_registry.cor_temporaria(int(id), COR_CAMINHO)
	return true

func cancelar() -> void:
	_rodando = false
	if is_instance_valid(_registry):
		_registry.resetar_cores_algoritmo()
