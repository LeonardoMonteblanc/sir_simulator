extends PanelContainer

# Painel de controle de grafo: botao de reset visual.
# Futuramente pode ganhar botoes de algoritmo tambem.

signal reset_pressed

@onready var _btn_reset: Button = $Layout/Btns/BtnReset

func _ready() -> void:
	_btn_reset.pressed.connect(func(): reset_pressed.emit())

func set_estado(rodando_algoritmo: bool) -> void:
	# desabilita reset durante execucao de algoritmo
	if is_instance_valid(_btn_reset):
		_btn_reset.disabled = rodando_algoritmo
