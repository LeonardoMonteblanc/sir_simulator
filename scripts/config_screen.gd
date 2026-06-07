extends Control

@onready var spin_aves: SpinBox = $CenterContainer/PanelContainer/VBoxContainer/GridContainer/SpinBoxAves
@onready var opt_doenca: OptionButton = $CenterContainer/PanelContainer/VBoxContainer/GridContainer/OptionButtonDoenca
@onready var slider_vacina: HSlider = $CenterContainer/PanelContainer/VBoxContainer/GridContainer/HSliderVacina
@onready var opt_layout: OptionButton = $CenterContainer/PanelContainer/VBoxContainer/GridContainer/OptionButtonLayout
@onready var btn_iniciar: Button = $CenterContainer/PanelContainer/VBoxContainer/BtnIniciar

func _ready():
	spin_aves.value = SimConfig.params["num_agents"]
	slider_vacina.value = SimConfig.params["vac_coverage"] * 100
	btn_iniciar.pressed.connect(_on_btn_iniciar_pressed)

func _on_btn_iniciar_pressed():
	SimConfig.params["num_agents"] = int(spin_aves.value)
	SimConfig.params["disease"] = opt_doenca.get_item_text(opt_doenca.selected)
	SimConfig.params["vac_coverage"] = slider_vacina.value / 100.0
	SimConfig.params["layout_galinheiro"] = opt_layout.get_item_text(opt_layout.selected)
	
	get_tree().change_scene_to_file("res://mainSimulation.tscn")
