extends Panel

var historico_pontos: Array[Vector2] = []
var dia_atual: int = 0

@export var line_2d: Line2D 

func adicionar_ponto_grafico(dados: Dictionary) -> void:
	var inf = dados.get("infectados", 0)
	historico_pontos.append(Vector2(dia_atual * 20, inf * 5))
	dia_atual += 1
	
	if line_2d:
		line_2d.points = PackedVector2Array(historico_pontos)
