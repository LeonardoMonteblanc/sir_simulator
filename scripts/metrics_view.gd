extends Panel

@onready var line_s: Line2D = $VBoxContainer/ContainerGrafico/Line_S
@onready var line_e: Line2D = $VBoxContainer/ContainerGrafico/Line_E
@onready var line_i: Line2D = $VBoxContainer/ContainerGrafico/Line_I
@onready var line_r: Line2D = $VBoxContainer/ContainerGrafico/Line_R
@onready var line_d: Line2D = $VBoxContainer/ContainerGrafico/Line_D
@onready var container_grafico: Control = $VBoxContainer/ContainerGrafico

var historico: Dictionary = {"S": [], "E": [], "I": [], "R": [], "D": []}

func adicionar_ponto_grafico(contagens: Dictionary, total_aves: int) -> void:
	if total_aves == 0:
		return
	
	var altura = container_grafico.size.y
	var num_pontos = len(historico["S"])
	
	for state in ["S", "E", "I", "R", "D"]:
		var contagem = contagens.get(state, 0)
		var y = altura - (float(contagem) / float(total_aves)) * altura
		historico[state].append(Vector2(num_pontos * 20, y))
	
	_atualizar_graficos()

func _atualizar_graficos() -> void:
	if line_s:
		line_s.points = PackedVector2Array(historico["S"])
	if line_e:
		line_e.points = PackedVector2Array(historico["E"])
	if line_i:
		line_i.points = PackedVector2Array(historico["I"])
	if line_r:
		line_r.points = PackedVector2Array(historico["R"])
	if line_d:
		line_d.points = PackedVector2Array(historico["D"])

func reset() -> void:
	historico = {"S": [], "E": [], "I": [], "R": [], "D": []}
	if line_s:
		line_s.points = PackedVector2Array()
	if line_e:
		line_e.points = PackedVector2Array()
	if line_i:
		line_i.points = PackedVector2Array()
	if line_r:
		line_r.points = PackedVector2Array()
	if line_d:
		line_d.points = PackedVector2Array()
