extends Control

signal closed

func _ready():
	_on_Settings_visibility_changed()
	var musicVal = BGM.normalizeDBtoVal(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("BGM")))
	$PauseCtrl/VBoxContainer/HBoxContainer/HSliderMusic.value = musicVal
	var SFXval = BGM.normalizeDBtoVal(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")))
	$PauseCtrl/VBoxContainer/HBoxContainer2/HSliderSFX.value = SFXval

func _process(delta):
	
	if Input.is_action_pressed("ui_cancel") and visible:
		emit_signal("closed")

func _on_ResumeBtn_pressed():
	emit_signal("closed")
	$ButtonClickedSFX.play()

func _on_HSliderMusic_value_changed(value):
	var val = BGM.normalizeValToDB(value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BGM"), val)
	if not $SliderUpdatedSFX.playing and visible:
		$SliderUpdatedSFX.play()


func _on_HSliderSFX_value_changed(value):
	var val = BGM.normalizeValToDB(value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), val)
	if not $SliderUpdatedSFX.playing and visible:
		$SliderUpdatedSFX.play()


func _on_Settings_visibility_changed():
	if visible:
		set_process_input(true)
		$PauseCtrl/ResumeBtn.grab_focus()
	else:
		set_process_input(false)


func _on_ResumeBtn_mouse_entered():
	$ButtonHoveredSFX.play()
