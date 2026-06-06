# tests/test_seird.gd

extends SceneTree

# Função principal de entrada para execução headless
func _ready():
	# 1. Criação Manual de um Grafo Simples.
	# Define 3 nós conectados em linha: 0 <-> 1 <-> 2.
	# Simula a estrutura de adjacência que o GraphGenerator fornecerá no futuro.
	var adj_teste: Dictionary = {
		0: [ { "neighbor_id": 1, "weight": 1.0 } ],
		1: [ { "neighbor_id": 0, "weight": 1.0 }, { "neighbor_id": 2, "weight": 1.0 } ],
		2: [ { "neighbor_id": 1, "weight": 1.0 } ]
	}
	
	# 2. Configuração de Parâmetros da Simulação.
	# Define semente fixa para garantir que o teste seja sempre reproduzível.
	# Seleciona Newcastle como doença padrão para validação.
	var params: Dictionary = {
		"seed": 42,
		"disease": "Newcastle",
		"num_agents": 3,
		"num_females": 2,
		"vac_coverage": 0.0
	}
	
	# 3. Instanciação e Inicialização do Modelo.
	# Cria o objeto SEIRDModel e carrega o estado inicial.
	# O paciente zero será definido automaticamente dentro deste método.
	var modelo = SEIRDModel.new()
	modelo.initialize(params, adj_teste)
	
	print("Iniciando teste de integridade do modelo SEIRD...")
	print("Agentes totais: ", params["num_agents"])
	print("---")
	
	# 4. Loop de Simulação e Validação de Invariantes.
	# Executa 30 passos (dias) e verifica a cada passo se a população se mantém constante.
	var houve_erro: bool = false
	
	for i in range(30):
		var res = modelo.step()
		
		# Soma todos os indivíduos em todos os estados epidemiológicos.
		var soma_estados: int = res["contagens"]["S"] + res["contagens"]["E"] + \
							   res["contagens"]["I"] + res["contagens"]["R"] + res["contagens"]["D"]
		
		# Verifica a invariante: O número total de agentes deve se manter constante.
		# Nenhum agente "nasce" ou "desaparece" no modelo SEIRD.
		if soma_estados != params["num_agents"]:
			print("ERRO NO DIA ", res["dia"], ": Soma dos estados (", soma_estados, 
				  ") difere do total de agentes (", params["num_agents"], ")")
			houve_erro = true
	
	# 5. Relatório Final e Encerramento.
	# Se nenhum erro foi encontrado, o modelo passesse no teste de consistência.
	if not houve_erro:
		print("Teste finalizado com SUCESSO. Nenhuma inconsistência encontrada.")
		print("Estado final: ", res["contagens"])
	
	# Encerra a árvore de cena para finalizar o script de teste.
	quit()
