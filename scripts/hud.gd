# res://scripts/hud.gd
extends PanelContainer

# Referências aos nós de exibição
@onready var label_dia: Label = %LabelDia 
@onready var label_suscetiveis: Label = %LabelSuscetiveis
@onready var label_infectados: Label = %LabelInfectados
@onready var label_mortos: Label = %LabelMortos
@onready var label_recuperados: Label = %LabelRecuperados
@onready var label_aves: Label = %LabelAves
@onready var label_expostos: Label = %LabelExpostos

signal solicitar_intervencao(tipo: String)
signal encerrar_simulacao_solicitado

func _ready() -> void:
	%BtnVacinar.pressed.connect(_on_btn_vacinar_pressed)
	%BtnIsolar.pressed.connect(_on_btn_isolar_pressed)
	%BtnEncerrar.pressed.connect(_on_btn_encerrar_pressed)
	
func atualizar_interface(dados: Dictionary) -> void:
	label_dia.text = "Dia %d" % dados.get("dia", 0)
	label_suscetiveis.text = "Suscetíveis: %d" % dados.get("suscetiveis", 0)
	label_infectados.text = "Infectados: %d" % dados.get("infectados", 0)
	label_mortos.text = "Mortos: %d" % dados.get("mortos", 0)
	label_recuperados.text = "Recuperados: %d" % dados.get("recuperados", 0)
	label_aves.text = "Aves: %d" % (dados.get("suscetiveis", 0) + dados.get("expostos", 0) + dados.get("infectados", 0) + dados.get("recuperados", 0))
	label_expostos.text = "Expostos: %d" % dados.get("expostos", 0)
	

func _on_btn_encerrar_pressed() -> void:
	encerrar_simulacao_solicitado.emit()
	
func _on_btn_vacinar_pressed() -> void:
	solicitar_intervencao.emit("vacinar")

func _on_btn_isolar_pressed() -> void:
	solicitar_intervencao.emit("isolar")
