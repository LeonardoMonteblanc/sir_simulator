extends Node

var params: Dictionary = {
	"num_agents": 10,
	"disease": "Newcastle",
	"layout": "Grid",
	"seed": 0,
	"egg_price": 0.7,
	"bird_price": 30.0
}


func aplicar_configuracoes(num_agents: int,doenca: String,layout: String) -> void:
	params["num_agents"] = num_agents
	params["disease"] = doenca
	params["layout"] = layout
	
