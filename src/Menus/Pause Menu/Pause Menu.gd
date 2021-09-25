extends MarginContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	if $Settings.connect("closed", self, "hideSettings"):
		print("Settings failed to connect?")

func _on_ResumeBtn_pressed():
	if GameManager.stage != null:
		Input.set_mouse_mode(Input.mouse_mod)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	self.hide()
	get_tree().paused = false


func _on_OptionsBtn_pressed():
	$Settings.show()
	$ClickSFX.play()


func _on_QuitBtn_pressed():
	$ClickSFX.play()
	get_tree().paused = false
	var scenePathToChangeTo = "res://Levels/LevelSelect/LevelSelect.tscn"
	if get_tree().get_current_scene().name == "Map" or GameManager.stage == 0:
		scenePathToChangeTo = "res://Menus/Main Menu.tscn"
	SceneTransition.transitionToScene(scenePathToChangeTo)


func hideSettings():
	$ClickSFX.play()
	$Settings.hide()
	$PauseCtrl/VBoxContainer/OptionsBtn.grab_focus()


func _on_Btn_mouse_entered():
	$HoverSFX.play()


func _unhandled_input(event):
	if event is InputEventKey:
		var pauseButtonHit = Input.is_action_pressed("ui_cancel") or Input.is_action_pressed("pause")
		if pauseButtonHit and visible and $Settings.visible == false:
			_on_ResumeBtn_pressed()
			get_tree().get_root().set_input_as_handled()


func _on_Pause_Menu_visibility_changed():
	if visible:
		$PauseCtrl/VBoxContainer/ResumeBtn.grab_focus()

func _exit_tree():
	get_tree().paused = false	# if the pause menu disappears for any reason, the tree should not be paused anymore, since this should only happen on transitions
