extends Node

# Controller isolado de simulacao automatica (play/pause/stop) para a SEIRD view.
# Vive em core_extensions/auto_simulation/. Se deletado, basta nao anexar este node
# e a view volta ao modo manual (passo a passo).
#
# API publica (consumida por simulation_view ou hud):
#   start(speed_seconds = 1.0)
#   pause()
#   resume()
#   stop()
#   is_running() -> bool
#
# Sinais:
#   tick                     : emitido a cada passo automatico
#   finished                 : emitido quando stop() limpa o timer
#
# O controller NAO conhece o modelo SEIRD. Ele apenas emite tick, e quem assina
# (simulation_view) decide o que fazer (avancar um passo).

signal tick
signal finished

var _timer: Timer
var _rodando: bool = false

func _ready() -> void:
	_timer = Timer.new()
	_timer.one_shot = false
	_timer.autostart = false
	_timer.timeout.connect(_on_timeout)
	add_child(_timer)

func start(speed_seconds: float = 1.0) -> void:
	if not is_instance_valid(_timer):
		_ready()
	_timer.wait_time = maxf(speed_seconds, 0.05)  # limite minimo pra nao fritar cpu
	_timer.start()
	_rodando = true

func pause_simulation() -> void:
	if not is_instance_valid(_timer):
		return
	_timer.paused = true

func resume() -> void:
	if not is_instance_valid(_timer):
		return
	# se nao estava rodando, comeca do zero
	if _timer.time_left <= 0.0 and not _rodando:
		start(_timer.wait_time)
		return
	_timer.paused = false
	_rodando = true

func stop() -> void:
	if is_instance_valid(_timer):
		_timer.stop()
		_timer.paused = false
	_rodando = false
	finished.emit()

func is_running() -> bool:
	if not is_instance_valid(_timer):
		return false
	return _rodando and not _timer.paused

func is_paused() -> bool:
	if not is_instance_valid(_timer):
		return false
	return _rodando and _timer.paused

func get_speed() -> float:
	if not is_instance_valid(_timer):
		return 1.0
	return _timer.wait_time

func set_speed(speed_seconds: float) -> void:
	if not is_instance_valid(_timer):
		return
	var novo: float = maxf(speed_seconds, 0.05)
	var estava_rodando: bool = _rodando and not _timer.paused
	_timer.stop()
	_timer.wait_time = novo
	if estava_rodando:
		_timer.start()

func _on_timeout() -> void:
	tick.emit()
