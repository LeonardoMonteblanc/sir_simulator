extends SceneTree

# Testa AutoSimulationController isoladamente.

var _ticks: int = 0
var _finished: bool = false

func _on_tick() -> void:
	_ticks += 1

func _on_finished() -> void:
	_finished = true

func _init():
	var Script = load("res://scripts/core_extensions/auto_simulation/auto_simulation_controller.gd")
	if Script == null:
		printerr("FAIL load controller")
		quit(1)
		return
	var holder := Node.new()
	root.add_child(holder)
	var ctrl = Script.new()
	holder.add_child(ctrl)
	await process_frame
	ctrl.tick.connect(_on_tick)
	ctrl.finished.connect(_on_finished)
	# 1) start com speed 0.2
	ctrl.start(0.2)
	if not ctrl.is_running():
		printerr("FAIL start nao ficou rodando")
		quit(1)
		return
	print("OK start: rodando=", ctrl.is_running(), " speed=", ctrl.get_speed())
	# 2) espera 1.0s
	await create_timer(1.0).timeout
	if _ticks < 2:
		printerr("FAIL ticks insuficiente: ", _ticks)
		quit(1)
		return
	print("OK ticks=", _ticks, " em 1.0s com speed=0.2")
	# 3) pause
	var ticks_pausado: int = _ticks
	ctrl.pause_simulation()
	if not ctrl.is_paused():
		printerr("FAIL pause nao pausou")
		quit(1)
		return
	print("OK pause is_paused=", ctrl.is_paused())
	await create_timer(0.5).timeout
	if _ticks > ticks_pausado:
		printerr("FAIL tickou apos pause: delta=", _ticks - ticks_pausado)
		quit(1)
		return
	print("OK nenhum tick durante pause (delta=", _ticks - ticks_pausado, ")")
	# 4) resume
	ctrl.resume()
	if not ctrl.is_running():
		printerr("FAIL resume nao retomou")
		quit(1)
		return
	await create_timer(0.5).timeout
	if _ticks <= ticks_pausado:
		printerr("FAIL sem tick apos resume: total=", _ticks)
		quit(1)
		return
	print("OK resume ticks cresceram para ", _ticks)
	# 5) set_speed
	ctrl.set_speed(0.5)
	if abs(ctrl.get_speed() - 0.5) > 0.01:
		printerr("FAIL set_speed nao alterou: ", ctrl.get_speed())
		quit(1)
		return
	print("OK set_speed=0.5")
	# 6) stop
	ctrl.stop()
	if ctrl.is_running():
		printerr("FAIL stop nao parou")
		quit(1)
		return
	if not _finished:
		printerr("FAIL finished nao foi emitido")
		quit(1)
		return
	print("OK stop + finished")
	print("VALIDATE_AUTOSIM_OK")
	quit(0)
