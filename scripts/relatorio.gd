extends Control

func _ready() -> void:
	$VBoxContainer/BtnFechar.pressed.connect(_on_btn_fechar_pressed)

func popular(summary: Dictionary, _historico: Dictionary) -> void:
	var total_aves = summary.get("total_aves", 0)
	var qtd_mortos = summary.get("qtd_mortos", 0)
	var prejuizo = summary.get("prejuizo", 0.0)
	var ovos_perdidos = summary.get("ovos_perdidos_total", 0.0)
	var dia_pico = summary.get("dia_pico_infectados", 0)
	var qtd_pico = summary.get("qtd_pico_infectados", 0)
	var dia_prim = summary.get("dia_prim_infectado", 0)
	var dia_ult = summary.get("dia_ult_morte", -1)
	var dia_final = summary.get("dia_final", 0)
	
	$VBoxContainer/TopMetrics/PanelMortos/LabelMortos.text = "Mortos: %d" % qtd_mortos
	
	var taxa_mortalidade = 0.0
	if total_aves > 0:
		taxa_mortalidade = (float(qtd_mortos) / float(total_aves)) * 100
	$VBoxContainer/TopMetrics/PanelTaxaMortalidade/LabelTaxaMortalidade.text = "Taxa: %.1f%%" % taxa_mortalidade
	
	var dozias = int(ovos_perdidos / 12.0)
	$VBoxContainer/TopMetrics/PanelOvosPerdidos/LabelOvosPerdidos.text = "Ovos: %.0f (%.0f dúzias)" % [ovos_perdidos, dozias]
	$VBoxContainer/TopMetrics/PanelPrejuizo/LabelPrejuizo.text = "Prejuízo: R$ %.2f" % prejuizo

	$VBoxContainer/CenterContainer/TimelineEvents/LabelPacienteZero.text = "Paciente zero: dia %d" % dia_prim
	$VBoxContainer/CenterContainer/TimelineEvents/LabelPico.text = "Pico: dia %d (%d infectados)" % [dia_pico, qtd_pico]

	if dia_ult >= 0:
		$VBoxContainer/CenterContainer/TimelineEvents/LabelUltimaMorte.text = "Última morte: dia %d" % dia_ult
	else:
		$VBoxContainer/CenterContainer/TimelineEvents/LabelUltimaMorte.text = "Última morte: nenhuma"

	$VBoxContainer/LabelFinal.text = "Em %d dias, você teria perdido %d aves e %.0f dúzias de ovos, totalizando R$ %.2f" % [
		dia_final, qtd_mortos, dozias, prejuizo
	]
	
	_desenhar_graficos()

func _desenhar_graficos() -> void:
	var graph_container = $VBoxContainer/CenterContainer/GraphContainer
	graph_container.queue_redraw()

func _on_btn_fechar_pressed() -> void:
	get_tree().paused = false
	queue_free()
