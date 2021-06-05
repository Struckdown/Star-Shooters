extends Control

signal closed

func _ready():
	_on_Settings_visibility_changed()
	var musicVal = normalizeDBtoVal(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("BGM")))
	$PauseCtrl/VBoxContainer/HBoxContainer/HSliderMusic.value = musicVal
	var SFXval = normalizeDBtoVal(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")))
	$PauseCtrl/VBoxContainer/HBoxContainer2/HSliderSFX.value = SFXval


func _on_ResumeBtn_pressed():
	emit_signal("closed")

func _on_HSliderMusic_value_changed(value):
	var val = normalizeValToDB(value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BGM"), val)
	if not $AudioStreamPlayer.playing:
		$AudioStreamPlayer.play()


func _on_HSliderSFX_value_changed(value):
	var val = normalizeValToDB(value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), val)
	if not $AudioStreamPlayer.playing:
		$AudioStreamPlayer.play()


func normalizeValToDB(val):
	var newVal = 0
	newVal = val*0.5
	newVal -= 50
	return newVal

func normalizeDBtoVal(DB):
	var val = DB + 50
	val *= 2
	return val

func _on_Settings_visibility_changed():
	if visible:
		set_process_input(true)
	else:
		set_process_input(false)