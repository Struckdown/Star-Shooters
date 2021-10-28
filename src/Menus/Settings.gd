extends Control

var optionsFileName = "user://player.perfs"
signal closed
var fileLock = false

func _ready():
	loadSettings()
	_on_Settings_visibility_changed()
	var musicVal = BGM.normalizeDBtoVal(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("BGM")))
	$PauseCtrl/VBoxContainer/HBoxContainer/HSliderMusic.value = musicVal
	var SFXval = BGM.normalizeDBtoVal(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")))
	$PauseCtrl/VBoxContainer/HBoxContainer2/HSliderSFX.value = SFXval

func _input(_event):
	if (Input.is_action_pressed("ui_cancel") or Input.is_action_pressed("pause"))and visible:
		emit_signal("closed")

func _process(_delta):
	pass
	
func _on_ResumeBtn_pressed():
	emit_signal("closed")
	$ButtonClickedSFX.play()

func _on_HSliderMusic_value_changed(value):
	var val = BGM.normalizeValToDB(value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BGM"), val)
	if not $SliderUpdatedSFX.playing and visible:
		$SliderUpdatedSFX.play()
	save()

func _on_HSliderSFX_value_changed(value):
	var val = BGM.normalizeValToDB(value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), val)
	if not $SliderUpdatedSFX.playing and visible:
		$SliderUpdatedSFX.play()
	save()

func _on_Settings_visibility_changed():
	if visible:
		set_process_input(true)
		$PauseCtrl/ResumeBtn.grab_focus()
	else:
		set_process_input(false)

func _on_ResumeBtn_mouse_entered():
	$ButtonHoveredSFX.play()

func save():
	if fileLock:
		return
	fileLock = true
	var save_file = File.new()
	save_file.open(optionsFileName, File.WRITE)
	var bgm = $PauseCtrl/VBoxContainer/HBoxContainer/HSliderMusic.value
	var sfx = $PauseCtrl/VBoxContainer/HBoxContainer2/HSliderSFX.value
	var speed = $PauseCtrl/VBoxContainer/HBoxContainer3/HSliderSpeed.value
	save_file.store_var(bgm)
	save_file.store_var(sfx)
	save_file.store_var(speed)
	save_file.close()
	fileLock = false
	

func loadSettings():
	if fileLock:
		return
	fileLock = true
	var save_file = File.new()
	if save_file.file_exists(optionsFileName):
		save_file.open(optionsFileName, File.READ)
		var bgm = save_file.get_var()
		var sfx = save_file.get_var()
		var speed = save_file.get_var()
		$PauseCtrl/VBoxContainer/HBoxContainer/HSliderMusic.value = bgm
		$PauseCtrl/VBoxContainer/HBoxContainer2/HSliderSFX.value = sfx
		$PauseCtrl/VBoxContainer/HBoxContainer3/HSliderSpeed.value = speed
		save_file.close()
	fileLock = false


func _on_HSliderSpeed_value_changed(value):
	GameManager.gameSpeed = value
	if not $SliderUpdatedSFX.playing and visible:
		$SliderUpdatedSFX.play()
	save()


func _on_Checkbox_toggled(button_pressed):
	OS.window_fullscreen = button_pressed
