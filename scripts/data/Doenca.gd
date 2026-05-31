class_name Doenca

extends RefCounted

var nome:String
var taxa_transmissao: float
var duracao_infeccao: float


func _init(
	p_nome: String,
	p_taxa_transmissao: float,
	p_duracao_infeccao: float
):
	nome = p_nome
	taxa_transmissao = p_taxa_transmissao
	duracao_infeccao = p_duracao_infeccao
	
