extends PanelContainer

# Painel de controles play/pause/stop + slider de velocidade.
# Componente isolado de UI. Quem consome o controller de auto-sim
# (scripts/core_extensions/auto_simulation/) recebe os sinais deste painel.
#
# Sinais emitidos (consumidos por quem precisar):
#   play_pressed
#   pause_pressed
#   stop_pressed
#   speed_changed(speed_seconds: float)

signal play_pressed
signal pause_pressed
signal stop_pressed
signal speed_changed(speed_seconds: float)

@onready var _btn_play: Button = $Layout/Botoes/BtnPlay
@onready var _btn_pause: Button = $Layout/Botoes/BtnPause
@onready var _btn_stop: Button = $Layout/Botoes/BtnStop
@onready var _slider: HSlider = $Layout/SliderVelocidade
@onready var _label_vel: Label = $Layout/SliderVelocidade/LabelVel

const VEL_MIN: float = 0.1
const VEL_MAX: float = 3.0
const VEL_PADRAO: float = 1.0

func _ready() -> void:
	_btn_play.pressed.connect(_on_play_pressed)
	_btn_pause.pressed.connect(_on_pause_pressed)
	_btn_stop.pressed.connect(_on_stop_pressed)
	_slider.min_value = VEL_MIN
	_slider.max_value = VEL_MAX
	_slider.step = 0.1
	_slider.value = VEL_PADRAO
	_slider.value_changed.connect(_on_slider_changed)
	_atualizar_label_vel(VEL_PADRAO)

func _on_play_pressed() -> void:
	play_pressed.emit()

func _on_pause_pressed() -> void:
	pause_pressed.emit()

func _on_stop_pressed() -> void:
	stop_pressed.emit()

func _on_slider_changed(value: float) -> void:
	_atualizar_label_vel(value)
	speed_changed.emit(value)

func _atualizar_label_vel(value: float) -> void:
	if is_instance_valid(_label_vel):
		_label_vel.text = "%.1fs/dia" % value

func set_estado(rodando: bool, pausado: bool) -> void:
	# feedback visual simples: desabilita botao que nao faz sentido no estado atual
	if is_instance_valid(_btn_play):
		_btn_play.disabled = rodando and not pausado
	if is_instance_valid(_btn_pause):
		_btn_pause.disabled = not rodando or pausado
	if is_instance_valid(_btn_stop):
		_btn_stop.disabled = not rodando and not pausado
