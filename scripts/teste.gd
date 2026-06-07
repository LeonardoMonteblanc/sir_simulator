# scripts/teste.gd
extends MainLoop

# VARIÁVEIS DE CLASSE ---------------------------------------------------
var modelo: SEIRDModel
var params: Dictionary
var passo_atual: int = 0
var passos_totais: int = 30

# FUNÇÃO DE INICIALIZAÇÃO ---------------------------------------------------
func _initialize() -> void:
	print("==================================================")
	print("INICIANDO TESTE DE INTEGRAÇÃO: GRAFO + SEIRD")
	print("==================================================")
	
	# 1. Configuração dos Parâmetros Globais da Simulação
	params = {
		"seed": 42,
		"disease": "Newcastle",
		"num_agents": 50,
		"num_females": 35,
		"vac_coverage": 0.1,
		"egg_price": 0.50,
		"bird_price": 25.0
	}
	
	print("População configurada: ", params["num_agents"], " agentes.")
	print("Layout selecionado para teste: FREE_RANGE")
	print("---")
	
	# 2. Instanciação e Execução do Gerador de Grafos
	var gerador := GraphGenerator.new()
	var resultado_grafo: Dictionary = gerador.generate(
		params["num_agents"], 
		"free_range"
	)
	
	var malha_adjacencia: Dictionary = resultado_grafo["adjacency"]
	var coordenadas_nos: Dictionary = resultado_grafo["positions"]
	
	# Validação rápida de segurança da topologia gerada
	var soma_graus: int = 0
	for id_agente in malha_adjacencia.keys():
		soma_graus += malha_adjacencia[id_agente].size()
	
	var grau_medio: float = float(soma_graus) / float(params["num_agents"])
	print("Topologia gerada com sucesso. Grau médio da rede: ", "%0.2f" % grau_medio)
	print("---")
	
	# 3. Inicialização do Modelo Epidemiológico com a Malha Gerada
	modelo = SEIRDModel.new()
	modelo.initialize(params, malha_adjacencia)

# LAÇO DE EXECUÇÃO DO MAINLOOP ---------------------------------------------------
func _process(_delta: float) -> bool:
	if passo_atual < passos_totais:
		var resultado_dia: Dictionary = modelo.step()
		
		# Validação da invariante de conservação populacional
		var contagem = resultado_dia["contagens"]
		var total_agentes_verificado: int = (
			contagem["S"] + 
			contagem["E"] + 
			contagem["I"] + 
			contagem["R"] + 
			contagem["D"]
		)
		
		if total_agentes_verificado != params["num_agents"]:
			print(
				"[FALHA] INCONSISTÊNCIA NO DIA ", resultado_dia["dia"], 
				": Soma dos compartimentos (", total_agentes_verificado, 
				") diverge do total de agentes (", params["num_agents"], ")"
			)
			return true # Encerra o laço indicando erro
			
		passo_atual += 1
		return false # Continua para o próximo dia simulado
	else:
		print("==================================================")
		print("TESTE FINALIZADO COM SUCESSO")
		print("Dias simulados sem quebra de invariantes: ", passo_atual)
		print("Estado epidemiológico final: ", modelo._count_states())
		print("==================================================")
		return true # Encerra o script com sucesso
