extends Node

var params: Dictionary = {
	"seed": 32,
	"disease": "Newcastle",
	"num_agents": 10,
	"num_females": 7,
	"vac_coverage": 0.1,
	"egg_price": 0.5,
	"bird_price": 25.0,
	"layout_galinheiro": "free_range"
}

func reset_to_defaults() -> void:
	params = {
		"seed": 32,
		"disease": "Newcastle",
		"num_agents": 20,
		"num_females": 14,
		"vac_coverage": 0.1,
		"egg_price": 0.5,
		"bird_price": 25.0,
		"layout_galinheiro": "free_range"
	}

func is_valid() -> bool:
	return params.has("num_agents") and params.has("disease")

func num_females_for(quantity: int) -> int:
	# sempre consistente e menor ou igual a quantity
	return clamp(int(quantity) * 7 / 10, 0, int(quantity))
