extends Control


signal closed
var fileLock = false
var selectedRebindableControl = null
var selectedRebindableHBox = null

func _ready():
	loadSettings()
	$Window/TabContainer/General/VBoxContainer/HBoxContainer4/Checkbox.pressed = OS.window_fullscreen
	_on_Settings_visibility_changed()

func _input(event):
	if (Input.is_action_pressed("ui_cancel") or Input.is_action_pressed("pause")) and visible:
		emit_signal("closed")
		return
	if event.is_action_pressed("ui_change_tabs") and visible:
		var tabNumber = $Window/TabContainer.current_tab
		$Window/TabContainer.current_tab = (tabNumber+1)%$Window/TabContainer.get_child_count()
		$Window/ResumeBtn.call_deferred("grab_focus")


func _unhandled_input(event):
	if $Window/RebindControlsSelector.visible:
		InputEventKey
		InputMap.action_erase_events(selectedRebindableControl)
#		InputMap.action_erase_event(selectedRebindableControl, actions[-1])
		InputMap.action_add_event(selectedRebindableControl, event)
		displayNewInput(selectedRebindableHBox, OS.get_scancode_string(event.scancode))
		$Window/RebindControlsSelector.hide()
		selectedRebindableHBox = null
		selectedRebindableControl = null
		#TODO Save to game manager


func _process(_delta):
	pass
	
func _on_ResumeBtn_pressed():
	emit_signal("closed")
	$ButtonClickedSFX.play()

func _on_HSliderMusic_value_changed(value):
	if not $SliderUpdatedSFX.playing and visible:
		$SliderUpdatedSFX.play()
	GameManager.setBusAudio("BGM", value)

func _on_HSliderSFX_value_changed(value):
	if not $SliderUpdatedSFX.playing and visible:
		$SliderUpdatedSFX.play()
	GameManager.setBusAudio("SFX", value)

func _on_Settings_visibility_changed():
	if visible:
		set_process_input(true)
		$Window/ResumeBtn.grab_focus()
	else:
		set_process_input(false)

func _on_ResumeBtn_mouse_entered():
	$ButtonHoveredSFX.play()

#func save():
#	if fileLock:
#		return
#	fileLock = true
#	var config = ConfigFile.new()
#	var err = config.load(optionsFileName)
#	if err:	# file does not exist
#		null
#	var bgm = $Window/TabContainer/General/VBoxContainer/HBoxContainer/HSliderMusic.value
#	var sfx = $Window/TabContainer/General/VBoxContainer/HBoxContainer2/HSliderSFX.value
#	var speed = $Window/TabContainer/General/VBoxContainer/HBoxContainer3/HSliderSpeed.value
#	var instaKill = $Window/TabContainer/General/VBoxContainer/HBoxContainer4/Checkbox2.pressed
#	GameManager.
#	config.set_value("audio", "bgm", bgm)
#	config.set_value("audio", "sfx", sfx)
#	config.set_value("gameplay", "speed", speed)
#	config.set_value("gameplay", "instaKill", instaKill)
#
#	for action in InputMap.get_actions():
#		config.set_value("input", action, OS.get_scancode_string(InputMap.get_action_list(action)[0].scancode))
#	config.save(optionsFileName)
#	fileLock = false
	

# Loads game world settings
func loadSettings():
	$Window/TabContainer/General/VBoxContainer/HBoxContainer/HSliderMusic.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("BGM"))
	$Window/TabContainer/General/VBoxContainer/HBoxContainer2/HSliderSFX.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))
	$Window/TabContainer/General/VBoxContainer/HBoxContainer3/HSliderSpeed.value = GameManager.gameSpeed
	$Window/TabContainer/General/VBoxContainer/HBoxContainer4/Checkbox2.pressed = GameManager.instaKillMode
	
	for action in InputMap.get_actions():
		var nodeName = "Window/TabContainer/Controls/ScrollContainer/VBoxContainer/" + action
		if has_node(nodeName):
			var scannedCodeString = GameManager.getActionString(action)
			var hbox = get_node(nodeName)
			displayNewInput(hbox, scannedCodeString)


func _on_HSliderSpeed_value_changed(value):
	GameManager.gameSpeed = value
	if not $SliderUpdatedSFX.playing and visible:
		$SliderUpdatedSFX.play()



func _on_Checkbox_toggled(button_pressed):
	OS.window_fullscreen = button_pressed


func _on_Checkbox2_toggled(button_pressed):
	GameManager.instaKillMode = button_pressed



func _on_RebindableBtn_pressed(rebindableControl):
	selectedRebindableControl = rebindableControl
	var focusOwner = get_focus_owner()
	if focusOwner:
		focusOwner.release_focus()
	selectedRebindableHBox = get_node("Window/TabContainer/Controls/ScrollContainer/VBoxContainer/" + selectedRebindableControl)
	$Window/RebindControlsSelector.show()
	$Window/RebindControlsSelector/RebindInstructionsBG/RebindInstructions.text = "Press the new input for: " + selectedRebindableHBox.get_child(0).text

func resetControls():
	for action in InputMap.get_actions():
		for val in action:
			var btn = InputEventKey.new()
			btn.scancode = val
			var hbox = get_node("Window/TabContainer/Controls/ScrollContainer/VBoxContainer/" + action)
			displayNewInput(hbox, btn.as_text())

func _on_ResetBtn_pressed():
	GameManager.resetControls()

func displayNewInput(hbox:HBoxContainer, text):
	if hbox == null or text == null:
		return
	hbox.get_child(2).text = text
#	get_node("Window/TabContainer/ControlsCtrl/ScrollContainer/VBoxContainer/" + selectedRebindableControl + "/RebindableBtn").text = event.as_text()
