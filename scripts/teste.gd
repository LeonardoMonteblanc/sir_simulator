# scripts/teste.gd

extends MainLoop

var modelo: SEIRDModel
var params: Dictionary
var passo_atual: int = 0
var passos_totais: int = 30

func _initialize():
	print("Iniciando teste de integridade do modelo SEIRD...")
	print("Agentes totais: 3")
	print("---")
	
	var adj_teste: Dictionary = {
		0: [ { "neighbor_id": 1, "weight": 1.0 } ],
		1: [ { "neighbor_id": 0, "weight": 1.0 }, { "neighbor_id": 2, "weight": 1.0 } ],
		2: [ { "neighbor_id": 1, "weight": 1.0 } ]
	}
	
	params = {
		"seed": 32,
		"disease": "Newcastle",
		"num_agents": 3,
		"num_females": 2,
		"vac_coverage": 0.0
	}
	
	modelo = SEIRDModel.new()
	modelo.initialize(params, adj_teste)

func _process(_delta: float) -> bool:
	# O bloco condicional controla a iteração diária da simulação até o limite estipulado
	# Por padrão, o MainLoop encerra quando retorna true e continua quando retorna false
	if passo_atual < passos_totais:
		var resultado_dia = modelo.step()
		
		# Validação da integridade do tamanho da população simulada a cada passo temporal
		var total_agentes_verificado: int = resultado_dia["contagens"]["S"] + resultado_dia["contagens"]["E"] + \
							   resultado_dia["contagens"]["I"] + resultado_dia["contagens"]["R"] + resultado_dia["contagens"]["D"]
		
		if total_agentes_verificado != params["num_agents"]:
			print("ERRO NO DIA ", resultado_dia["dia"], ": Soma dos estados (", total_agentes_verificado, 
				  ") difere do total de agentes (", params["num_agents"], ")")
			return true
		
		passo_atual += 1
		return false
	else:
		# Finalização limpa do script exibindo os resultados consolidados acumulados
		# Retorna true para instruir o Godot a desalocar o MainLoop com sucesso
		print("Teste finalizado com SUCESSO. Nenhuma inconsistência encontrada.")
		print("Estado final: ", modelo._count_states())
		return true