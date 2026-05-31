extends  Node2D

func _ready():

	var covid = Doenca.new(
		"COVID",
		0.35,
		8.0
	)

	print(covid.nome)
	print(covid.taxa_transmissao)
	print(covid.duracao_infeccao)
