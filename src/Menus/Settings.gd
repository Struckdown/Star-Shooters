extends Control

var optionsFileName = "user://player.perfs"
signal closed
var fileLock = false
var selectedRebindableControl = null
var selectedRebindableHBox = null

func _ready():
	loadSettings()
	$Window/TabContainer/General/VBoxContainer/HBoxContainer4/Checkbox.pressed = OS.window_fullscreen
	_on_Settings_visibility_changed()

func _input(_event):
	if (Input.is_action_pressed("ui_cancel") or Input.is_action_pressed("pause")) and visible:
		emit_signal("closed")

func _unhandled_input(event):
	if $Window/RebindControlsSelector.visible:
		InputMap.action_erase_events(selectedRebindableControl)
#		InputMap.action_erase_event(selectedRebindableControl, actions[-1])
		InputMap.action_add_event(selectedRebindableControl, event)
		displayNewInput(selectedRebindableHBox)
		$Window/RebindControlsSelector.hide()
		selectedRebindableHBox = null
		selectedRebindableControl = null
		save()


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
		$Window/ResumeBtn.grab_focus()
	else:
		set_process_input(false)

func _on_ResumeBtn_mouse_entered():
	$ButtonHoveredSFX.play()

func save():
	if fileLock:
		return
	fileLock = true
	var config = ConfigFile.new()
	var err = config.load(optionsFileName)
	if err:	# file does not exist
		print("No previous config detected")
	var bgm = $Window/TabContainer/General/VBoxContainer/HBoxContainer/HSliderMusic.value
	var sfx = $Window/TabContainer/General/VBoxContainer/HBoxContainer2/HSliderSFX.value
	var speed = $Window/TabContainer/General/VBoxContainer/HBoxContainer3/HSliderSpeed.value
	var instaKill = $Window/TabContainer/General/VBoxContainer/HBoxContainer4/Checkbox2.pressed
	config.set_value("audio", "bgm", bgm)
	config.set_value("audio", "sfx", sfx)
	config.set_value("gameplay", "speed", speed)
	config.set_value("gameplay", "instaKill", instaKill)
		
	for action in InputMap.get_actions():
		config.set_value("input", action, OS.get_scancode_string(InputMap.get_action_list(action)[0].scancode))
	config.save(optionsFileName)
	fileLock = false
	

func loadSettings():
	if fileLock:
		return
	fileLock = true
	var config = ConfigFile.new()
	var err = config.load(optionsFileName)
	if not err:
		var bgm = config.get_value("audio", "bgm", 80.0)
		var sfx = config.get_value("audio", "sfx", 80.0)
		var speed = config.get_value("gameplay", "speed", 1)
		var instaKill = config.get_value("gameplay", "instakill", false)
		$Window/TabContainer/General/VBoxContainer/HBoxContainer/HSliderMusic.value = bgm
		_on_HSliderMusic_value_changed(bgm)
		$Window/TabContainer/General/VBoxContainer/HBoxContainer2/HSliderSFX.value = sfx
		_on_HSliderSFX_value_changed(sfx)
		$Window/TabContainer/General/VBoxContainer/HBoxContainer3/HSliderSpeed.value = speed
		$Window/TabContainer/General/VBoxContainer/HBoxContainer4/Checkbox2.pressed = instaKill
		
		for action in InputMap.get_actions():
			InputMap.action_erase_events(action)	# ckean up old actions
			var scannedCodeString = config.get_value("input", action)
			var inputEventKey = InputEventKey.new()
			inputEventKey.scancode = OS.find_scancode_from_string(scannedCodeString)
			InputMap.action_add_event(action, inputEventKey)
			var nodeName = "Window/TabContainer/Controls/ScrollContainer/VBoxContainer/" + action
			if has_node(nodeName):
				var hbox = get_node(nodeName)
				displayNewInput(hbox)
	fileLock = false


func _on_HSliderSpeed_value_changed(value):
	GameManager.gameSpeed = value
	if not $SliderUpdatedSFX.playing and visible:
		$SliderUpdatedSFX.play()
	save()


func _on_Checkbox_toggled(button_pressed):
	OS.window_fullscreen = button_pressed


func _on_Checkbox2_toggled(button_pressed):
	GameManager.instaKillMode = button_pressed
	save()


func _on_RebindableBtn_pressed(rebindableControl):
	selectedRebindableControl = rebindableControl
	var focusOwner = get_focus_owner()
	if focusOwner:
		focusOwner.release_focus()
	selectedRebindableHBox = get_node("Window/TabContainer/Controls/ScrollContainer/VBoxContainer/" + selectedRebindableControl)
	$Window/RebindControlsSelector.show()
	$Window/RebindControlsSelector/RebindInstructionsBG/RebindInstructions.text = "Press the new input for: " + selectedRebindableHBox.get_child(0).text

func resetControls():
	var actions = {"move_left": [KEY_A], "move_right": [KEY_D],
	"move_up":[KEY_W], "move_down":[KEY_S], "move_slow":[KEY_SHIFT],
	"fire":[KEY_Z], "switchWeapons":[KEY_R]
	}
	for action in actions:
		InputMap.action_erase_events(action)
		for val in actions[action]:
			var btn = InputEventKey.new()
			btn.scancode = val
			InputMap.action_add_event(action, btn)
			var hbox = get_node("Window/TabContainer/Controls/ScrollContainer/VBoxContainer/" + action)
			displayNewInput(hbox)


func _on_ResetBtn_pressed():
	resetControls()

func displayNewInput(hbox:HBoxContainer):
	var action = hbox.name
	hbox.get_child(2).text = InputMap.get_action_list(action)[0].as_text()
#	get_node("Window/TabContainer/ControlsCtrl/ScrollContainer/VBoxContainer/" + selectedRebindableControl + "/RebindableBtn").text = event.as_text()
