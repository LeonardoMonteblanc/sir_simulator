extends Node

@onready var infection_manager = $InfeccaoManager

var doenca_atual: Doenca

func _ready():
	doenca_atual.nome = "COVID"
	doenca_atual.taxa_transmissao = 0.3


func _process(delta):
	infection_manager.processar_infeccao()
