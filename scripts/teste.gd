# scripts/teste.gd

extends MainLoop

# VARIÁVEIS DE CLASSE ---------------------------------------------------
var visualizacao: Control
var passo_atual: int = 0
var passos_totais: int = 15
var erro_inicializacao: bool = false
var teste_finalizado: bool = false
var dicionario_ids_validos: Dictionary = {}

# FUNÇÃO DE INICIALIZAÇÃO ---------------------------------------------------
func _initialize() -> void:
	print("==================================================")
	print("INICIANDO TESTE DE INTEGRAÇÃO: PIPELINE VISUAL")
	print("==================================================")
	
	var script_visualizacao := preload("res://scripts/simulation_view.gd")
	visualizacao = Control.new()
	visualizacao.set_script(script_visualizacao)
	
	var editor_grafos := GraphEdit.new()
	editor_grafos.name = "GraphEdit"
	visualizacao.add_child(editor_grafos)
	
	visualizacao._ready()
	
	var total_nos_graficos: int = editor_grafos.get_child_count()
	print("Interface inicializada. Nós gráficos totais na View: ", total_nos_graficos)
	
	var modelo_puro: SEIRDModel = visualizacao.modelo_epidemiologico
	var lista_agentes: Array = modelo_puro.get_agents() if modelo_puro.has_method("get_agents") else modelo_puro.agentes
	print("Entidades lógicas mapeadas no modelo sanitário: ", lista_agentes.size())
	
	for agente_objeto in lista_agentes:
		dicionario_ids_validos[agente_objeto.id] = true
		
	for id_chave in dicionario_ids_validos:
		if not editor_grafos.has_node(str(id_chave)):
			print("[FALHA] Agente lógico com ID ", id_chave, " não possui correspondência na árvore visual.")
			teste_finalizado = true
			_finalizar_processo_sistema(1)
			return
			
	print("Mapeamento estruturado com sucesso. Nós extras de controle serão ignorados.")
	print("---")

# LAÇO DE EXECUÇÃO DO MAINLOOP ---------------------------------------------------
func _process(_delta: float) -> bool:
	if teste_finalizado:
		return true

	if erro_inicializacao:
		if is_instance_valid(visualizacao):
			visualizacao.free()
		teste_finalizado = true
		return true

	if passo_atual < passos_totais:
		var editor_grafos: GraphEdit = visualizacao.get_node("GraphEdit")
		visualizacao._on_step_pressed()
		
		var modelo_puro: SEIRDModel = visualizacao.modelo_epidemiologico
		var lista_agentes: Array = modelo_puro.get_agents() if modelo_puro.has_method("get_agents") else modelo_puro.agentes
		
		for agente_objeto in lista_agentes:
			var id_agente: int = agente_objeto.id
			# Correção: Acessa a propriedade unificada 'estado' mapeada no modelo real
			var estado_biologico: int = agente_objeto.estado
			
			var no_no_grafo := editor_grafos.get_node(str(id_agente)) as GraphNode
			var cor_verificacao: Color = visualizacao.CORES_ESTADOS[estado_biologico]
			
			if no_no_grafo.self_modulate != cor_verificacao:
				print("[FALHA] Desconexão visual no agente ", id_agente, ": Cor do nó diverge do estado epidemiológico real.")
				if visualizacao.has_method("limpar_simulacao"): 
					visualizacao.limpar_simulacao()
				visualizacao.free()
				teste_finalizado = true
				_finalizar_processo_sistema(1)
				return true
				
		passo_atual += 1
		return false
	else:
		print("==================================================")
		print("TESTE VISUAL FINALIZADO COM SUCESSO")
		print("Sincronização cromática validada por: ", passo_atual, " dias.")
		print("==================================================")
		
		if is_instance_valid(visualizacao):
			if visualizacao.has_method("limpar_simulacao"): 
				visualizacao.limpar_simulacao()
			visualizacao.free()
			
		teste_finalizado = true
		_finalizar_processo_sistema(0)
		return true

# ROTINA DE SAÍDA HEADLESS DO SISTEMA OPERACIONAL ----------------------------------
func _finalizar_processo_sistema(codigo_retorno: int) -> void:
	var id_processo: int = OS.get_process_id()
	print("Encerrando interpretador de testes com código de saída: ", codigo_retorno)
	OS.kill(id_processo)
