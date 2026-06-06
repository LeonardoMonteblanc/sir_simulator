class_name SEIRDModel
extends RefCounted


class Agente:
	var id: int
	var estado: SEIRDModel.Estado
	var days_int_state: int
	var latency_durantion: int
	


# Estados possíveis de um agente
enum Estado { S, E, I, R, D }

# Parâmetros para o algoritmo SEIRD
var beta: float          # probabilidade de transmissão por contato por dia
var delta: float         # probabilidade de morte ao sair de I
var latency_min: int     # duração mínima em E (dias)
var latency_max: int     # duração máxima em E (dias)
var infect_min: int      # duração mínima em I (dias)
var infect_max: int      # duração máxima em I (dias)

# Estado da simulação
var agents: Array        # Array de Agent
var adjacency: Dictionary  # { id: [ {neighbor_id, weight} ] }
var day: int

# Acumuladores de produção
var eggs_lost_today: float
var eggs_lost_total: float
var dead_count: int

# Eventos registrados para o relatório final
var day_first_infected: int
var day_peak_infected: int
var peak_infected_count: int
var day_last_death: int
