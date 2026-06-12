extends Control

@onready var spin_aves: SpinBox = $CenterContainer/PanelContainer/VBoxContainer/GridContainer/SpinBoxAves
@onready var opt_doenca: OptionButton = $CenterContainer/PanelContainer/VBoxContainer/GridContainer/OptionButtonDoenca
@onready var slider_vacina: HSlider = $CenterContainer/PanelContainer/VBoxContainer/GridContainer/HSliderVacina
@onready var label_valor_vacina: Label = $CenterContainer/PanelContainer/VBoxContainer/GridContainer/LabelValorVacina
@onready var label_info_doenca: Label = $CenterContainer/PanelContainer/VBoxContainer/GridContainer/LabelInfoDoenca
@onready var spin_seed: SpinBox = $CenterContainer/PanelContainer/VBoxContainer/GridContainer/SpinBoxSeedValue
@onready var spin_ovo: SpinBox = $CenterContainer/PanelContainer/VBoxContainer/GridContainer/SpinBoxOvoValue
@onready var spin_ave: SpinBox = $CenterContainer/PanelContainer/VBoxContainer/GridContainer/SpinBoxAveValue
@onready var opt_layout: OptionButton = $CenterContainer/PanelContainer/VBoxContainer/GridContainer/OptionButtonLayout
@onready var btn_iniciar: Button = $CenterContainer/PanelContainer/VBoxContainer/BtnIniciar

func _ready():
	SimConfig.reset_to_defaults()
	spin_aves.value = SimConfig.params["num_agents"]
	slider_vacina.value = SimConfig.params["vac_coverage"] * 100
	spin_seed.value = SimConfig.params.get("seed", 0)
	spin_ovo.value = SimConfig.params.get("egg_price", 0.7)
	spin_ave.value = SimConfig.params.get("bird_price", 30.0)
	
	opt_doenca.item_selected.connect(_on_doenca_selected)
	slider_vacina.value_changed.connect(_on_slider_vacina_changed)
	btn_iniciar.pressed.connect(_on_btn_iniciar_pressed)
	
	_on_doenca_selected(0)

func _on_doenca_selected(index: int) -> void:
	var doenca_nome = opt_doenca.get_item_text(index)
	var presets = SEIRDModel.DISEASE_PRESETS
	if presets.has(doenca_nome):
		var dados = presets[doenca_nome]
		var beta = dados.get("beta", 0.0)
		var delta = dados.get("delta", 0.0)
		var lethality = int(delta * 100)
		label_info_doenca.text = "β = %.2f  |  Letalidade: %d%%" % [beta, lethality]

func _on_slider_vacina_changed(value: float) -> void:
	label_valor_vacina.text = "%d%%" % int(value)

func _on_btn_iniciar_pressed():
	SimConfig.params["num_agents"] = int(spin_aves.value)
	SimConfig.params["disease"] = opt_doenca.get_item_text(opt_doenca.selected)
	SimConfig.params["vac_coverage"] = slider_vacina.value / 100.0
	SimConfig.params["layout_galinheiro"] = opt_layout.get_item_text(opt_layout.selected)
	SimConfig.params["seed"] = int(spin_seed.value)
	SimConfig.params["egg_price"] = spin_ovo.value
	SimConfig.params["bird_price"] = spin_ave.value
	
	get_tree().change_scene_to_file("res://scenes/mainSimulation.tscn")
