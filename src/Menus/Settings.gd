extends Control


signal closed
var fileLock = false
var selectedRebindableControl = null
var selectedRebindableHBox = null

func _ready():
	loadSettings()
	$Window/TabContainer/General/VBoxContainer/HBoxContainer4/Checkbox.pressed = OS.window_fullscreen
	_on_Settings_visibility_changed()
	var err = GameManager.connect("controlsChanged", self, "updateControlsDisplay")
	if err:
		push_error(err)


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
		InputMap.action_erase_events(selectedRebindableControl)
#		InputMap.action_erase_event(selectedRebindableControl, actions[-1])
		InputMap.action_add_event(selectedRebindableControl, event)
		displayNewInput(selectedRebindableHBox, OS.get_scancode_string(event.scancode))
		GameManager.config.set_value("input", selectedRebindableControl, event.scancode)
		GameManager.saveGame()
		$Window/RebindControlsSelector.hide()
		selectedRebindableHBox = null
		selectedRebindableControl = null


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


# Loads game world settings
func loadSettings():
	$Window/TabContainer/General/VBoxContainer/HBoxContainer/HSliderMusic.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("BGM"))
	$Window/TabContainer/General/VBoxContainer/HBoxContainer2/HSliderSFX.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))
	$Window/TabContainer/General/VBoxContainer/HBoxContainer3/HSliderSpeed.value = GameManager.gameSpeed
	$Window/TabContainer/General/VBoxContainer/HBoxContainer4/Checkbox2.pressed = GameManager.instaKillMode
	$Window/TabContainer/General/VBoxContainer/HBoxContainer4/Checkbox.pressed = OS.window_fullscreen
	updateControlsDisplay()


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

func updateControlsDisplay():
	for action in InputMap.get_actions():
		if has_node("Window/TabContainer/Controls/ScrollContainer/VBoxContainer/" + action):
			var hbox = get_node("Window/TabContainer/Controls/ScrollContainer/VBoxContainer/" + action)
			displayNewInput(hbox, InputMap.get_action_list(action)[0].as_text())

func _on_ResetBtn_pressed():
	GameManager.resetControls()

func displayNewInput(hbox:HBoxContainer, text):
	if hbox == null or text == null:
		return
	hbox.get_child(2).text = str(text)
