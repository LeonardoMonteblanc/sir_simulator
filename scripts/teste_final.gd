# res://scripts/test_scene.gd
extends Node

# Executado assim que a cena entra na árvore de execução
func _ready() -> void:
	print("=============================================")
	print("=== INICIANDO TESTE DE INTEGRAÇÃO EM CENA ===")
	print("=============================================")
	
	# Executa os métodos de verificação isolada
	_validar_fluxo_configuracao()
	_validar_estruturas_gerador()
	_validar_conservacao_populacao()
	
	print("\n=============================================")
	print("=== TODOS OS TESTES PASSARAM COM SUCESSO! ===")
	print("=============================================")

# Confirma que os parâmetros globais do Autoload são acessíveis e modificáveis
func _validar_fluxo_configuracao() -> void:
	print("\n[TESTE] Validando persistência do SimConfig...")
	
	# Verifica a presença das chaves básicas de controle epidemiológico
	assert(SimConfig.params.has("num_agents"), "Erro: SimConfig omitiu 'num_agents'")
	assert(SimConfig.params.has("layout_galinheiro"), "Erro: SimConfig omitiu 'layout_galinheiro'")
	
	# Modifica temporariamente para simular a ConfigScreen
	SimConfig.params["num_agents"] = 25
	SimConfig.params["layout_galinheiro"] = "single_pole"
	
	assert(SimConfig.params["num_agents"] == 25, "Erro: Falha na mutabilidade de 'num_agents'")
	print("[OK] SimConfig respondendo perfeitamente.")

# Garante que as funções de criação de rede geram o formato esperado sem quebra de referências
func _validar_estruturas_gerador() -> void:
	print("\n[TESTE] Validando topologias do GraphGenerator...")
	var instancia_gerador := GraphGenerator.new()
	var tipos_layouts = ["free_range", "single_pole", "two_poles"]
	
	for modelo_layout in tipos_layouts:
		var resultado_rede = instancia_gerador.generate(20, modelo_layout)
		assert(resultado_rede.has("adjacency"), "Erro: Faltando dicionário de adjacência no layout: " + modelo_layout)
		assert(resultado_rede.has("positions"), "Erro: Faltando dicionário de posições no layout: " + modelo_layout)
		
		var mapa_adjacencia: Dictionary = resultado_rede["adjacency"]
		assert(mapa_adjacencia.size() == 20, "Erro: Contagem de nós inválida no layout: " + modelo_layout)
		
		var contagem_conexoes = 0
		for conexoes_agente in mapa_adjacencia.values():
			contagem_conexoes += conexoes_agente.size()
			
		assert(contagem_conexoes > 0, "Erro: Malha gerou nós completamente isolados no layout: " + modelo_layout)
		print("[OK] Estrutura '%s' criada com %d conexões ativas." % [modelo_layout, contagem_conexoes])

# Proteção matemática para certificar que nenhuma ave desaparece ou surge por erro de arredondamento
func _validar_conservacao_populacao() -> void:
	print("\n[TESTE] Validando invariância de massa da simulação...")
	var total_aves_teste = 40
	
	var configuracao_teste = {
		"num_agents": total_aves_teste,
		"disease": "HPAI H5N1",
		"vac_coverage": 0.15,
		"layout_galinheiro": "two_poles"
	}
	
	var instancia_gerador := GraphGenerator.new()
	var grafo_construido = instancia_gerador.generate(total_aves_teste, "two_poles")
	
	var instancia_modelo := SEIRDModel.new()
	instancia_modelo.initialize(configuracao_teste, grafo_construido["adjacency"])
	
	# Simula 20 dias consecutivos para stress test da modelagem estocástica
	for dia_atual in range(1, 21):
		var dados_metricas: Dictionary = instancia_modelo.step()
		
		var soma_compartimentos = (
			dados_metricas.get("suscetiveis", 0) +
			dados_metricas.get("expostos", 0) +
			dados_metricas.get("infectados", 0) +
			dados_metricas.get("recuperados", 0) +
			dados_metricas.get("mortos", 0)
		)
		
		# Validação crucial do balanço populacional
		assert(soma_compartimentos == total_aves_teste, 
			"ERRO CRÍTICO no Dia %d: Balanço de aves falhou! Esperado %d, obtido %d" % [dia_atual, total_aves_teste, soma_compartimentos]
		)
		
	print("[OK] Balanço populacional S+E+I+R+D conservado estritamente por 20 iterações.")
