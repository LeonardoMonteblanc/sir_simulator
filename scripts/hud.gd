# res://scripts/hud.gd
extends PanelContainer

# HUD unificado: contadores SEIRD + botoes de intervencao
# (vacinar/isolar/encerrar) + controles de autoplay (play/pause/stop/slider).
# A cena de control_panel.tscn foi absorvida por esta cena.

# === Metricas ===
@onready var label_dia: Label = %LabelDia
@onready var label_suscetiveis: Label = %LabelSuscetiveis
@onready var label_infectados: Label = %LabelInfectados
@onready var label_mortos: Label = %LabelMortos
@onready var label_recuperados: Label = %LabelRecuperados
@onready var label_aves: Label = %LabelAves
@onready var label_expostos: Label = %LabelExpostos

# === Botoes de intervencao ===
@onready var _btn_vacinar: Button = %BtnVacinar
@onready var _btn_isolar: Button = %BtnIsolar
@onready var _btn_encerrar: Button = %BtnEncerrar

# === Controles de autoplay ===
@onready var _btn_play: Button = %BtnPlay
@onready var _btn_pause: Button = %BtnPause
@onready var _btn_stop: Button = %BtnStop
@onready var _slider: HSlider = %SliderVelocidade
@onready var _label_vel: Label = %LabelVel

const VEL_MIN: float = 0.1
const VEL_MAX: float = 3.0
const VEL_PADRAO: float = 1.0

# === Sinais existentes (intervencao + encerramento) ===
signal solicitar_intervencao(tipo: String)
signal encerrar_simulacao_solicitado

# === Sinais de autoplay (expostos para o main_simulation) ===
signal play_pressed
signal pause_pressed
signal stop_pressed
signal speed_changed(speed_seconds: float)

func _ready() -> void:
	_btn_vacinar.pressed.connect(_on_btn_vacinar_pressed)
	_btn_isolar.pressed.connect(_on_btn_isolar_pressed)
	_btn_encerrar.pressed.connect(_on_btn_encerrar_pressed)

	_btn_play.pressed.connect(_on_play_pressed)
	_btn_pause.pressed.connect(_on_pause_pressed)
	_btn_stop.pressed.connect(_on_stop_pressed)

	_slider.min_value = VEL_MIN
	_slider.max_value = VEL_MAX
	_slider.step = 0.1
	_slider.value = VEL_PADRAO
	_slider.value_changed.connect(_on_slider_changed)
	_atualizar_label_vel(VEL_PADRAO)

func atualizar_interface(dados: Dictionary) -> void:
	label_dia.text = "Dia %d" % dados.get("dia", 0)
	label_suscetiveis.text = "Suscetíveis: %d" % dados.get("suscetiveis", 0)
	label_infectados.text = "Infectados: %d" % dados.get("infectados", 0)
	label_mortos.text = "Mortos: %d" % dados.get("mortos", 0)
	label_recuperados.text = "Recuperados: %d" % dados.get("recuperados", 0)
	label_aves.text = "Aves: %d" % (dados.get("suscetiveis", 0) + dados.get("expostos", 0) + dados.get("infectados", 0) + dados.get("recuperados", 0))
	label_expostos.text = "Expostos: %d" % dados.get("expostos", 0)


# === Handlers de intervencao ===
func _on_btn_encerrar_pressed() -> void:
	encerrar_simulacao_solicitado.emit()

func _on_btn_vacinar_pressed() -> void:
	solicitar_intervencao.emit("vacinar")

func _on_btn_isolar_pressed() -> void:
	solicitar_intervencao.emit("isolar")

# === Handlers de autoplay ===
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
	_label_vel.text = "%.1fs/dia" % value

# Estado visual dos botoes de autoplay. Chamado por quem controla o timer.
func set_estado(rodando: bool, pausado: bool) -> void:
	# parado  -> play=on, pause=off, stop=off
	# rodando -> play=off, pause=on, stop=on
	# pausado -> play=on, pause=off, stop=on
	_btn_play.disabled = rodando and not pausado
	_btn_pause.disabled = (not rodando) or pausado
	_btn_stop.disabled = not rodando
