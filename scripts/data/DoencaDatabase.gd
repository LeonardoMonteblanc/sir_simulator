class_name DoencaDatabase
extends RefCounted

var doencas := {}

func _init():
	doencas["COVID"] = Doenca.new("COVID", 0.3, 8.0)
	doencas["DENGUE"] = Doenca.new("DENGUE", 0.15, 12.0)
	doencas["EBOLA"] = Doenca.new("EBOLA", 0.2, 20.0)

func get_doenca(nome: String) -> Doenca:
	return doencas.get(nome, null)

func listar_nomes() -> Array:
	return doencas.keys()
