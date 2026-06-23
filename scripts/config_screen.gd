# config_screen.gd
extends Control

signal simulacao_configurada(num_agents: int, disease: String, layout: String)

@onready var spin_aves: SpinBox = $PanelContainer/VBoxContainer/GridContainer/SpinBoxAves
@onready var opt_doenca: OptionButton = $PanelContainer/VBoxContainer/GridContainer/OptionButtonDoenca
@onready var label_info_doenca: Label = $PanelContainer/VBoxContainer/LabelInfoDoenca
@onready var opt_layout: OptionButton = $PanelContainer/VBoxContainer/GridContainer/OptionButtonLayout
@onready var btn_iniciar: Button = $PanelContainer/VBoxContainer/BtnIniciar


func _ready() -> void:
	spin_aves.value = SimConfig.params.get("num_agents", 10)
	opt_doenca.item_selected.connect(_on_doenca_selected)
	btn_iniciar.pressed.connect(_on_btn_iniciar_pressed)
	_on_doenca_selected(0)

func _on_doenca_selected(index: int) -> void:
	var doenca_nome: String = opt_doenca.get_item_text(index)
	
	
	if SEIRDModel.DISEASE_PRESETS.has(doenca_nome):
		var dados: Dictionary = SEIRDModel.DISEASE_PRESETS[doenca_nome]
		var beta: float = dados.get("beta", 0.0)
		var delta: float = dados.get("delta", 0.0)
		var lethality: int = int(delta * 100)
		
		label_info_doenca.text = "β = %.2f  |  Letalidade: %d%%" % [beta, lethality]
	else:
		label_info_doenca.text = "Informações não encontradas."

func _on_btn_iniciar_pressed() -> void:
	SimConfig.params["num_agents"] = int(spin_aves.value)
	SimConfig.params["disease"] = opt_doenca.get_item_text(opt_doenca.selected)
	SimConfig.params["layout"] = opt_layout.get_item_text(opt_layout.selected)
	simulacao_configurada.emit(
		int(spin_aves.value),
		opt_doenca.get_item_text(opt_doenca.selected),
		opt_layout.get_item_text(opt_layout.selected)
	)
