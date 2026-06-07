extends Panel

@onready var rotulo_metricas: Label = %Label
@onready var linha_grafico: Line2D = %Line2D

const PONTOS_MAXIMOS = 50

func atualizar_metricas_painel(dados: Dictionary):
	rotulo_metricas.text = "Suscetíveis: %d\nInfectados: %d\nPrejuízo: R$ %.2f" % [
		dados.get("suscetiveis", 0), dados.get("infectados", 0), dados.get("prejuizo", 0.0)
	]
	
	var novo_ponto = Vector2(linha_grafico.points.size() * 10, dados.get("infectados",0) * -1)
	linha_grafico.add_point(novo_ponto)
	
	if linha_grafico.points.size() > PONTOS_MAXIMOS:
		linha_grafico.remove_point(0)
		
		for i in range(linha_grafico.points.size()):
			linha_grafico.set_point_position(i, Vector2(i *10, linha_grafico.points[i].y))
	
	
