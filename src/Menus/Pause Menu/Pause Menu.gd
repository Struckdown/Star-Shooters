extends MarginContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	if $Settings.connect("closed", self, "hideSettings"):
		print("Settings failed to connect?")

func _on_ResumeBtn_pressed():
	self.hide()
	get_tree().paused = false


func _on_OptionsBtn_pressed():
	$Settings.show()
	$ClickSFX.play()


func _on_QuitBtn_pressed():
	$ClickSFX.play()
	get_tree().paused = false
	var scenePathToChangeTo = "res://Levels/LevelSelect/LevelSelect.tscn"
	if get_tree().get_current_scene().name == "Map":
		scenePathToChangeTo = "res://Menus/Main Menu.tscn"
	if(get_tree().change_scene(scenePathToChangeTo)):
		print("ERROR in screen change!")

func hideSettings():
	$ClickSFX.play()
	$Settings.hide()
	$PauseCtrl/VBoxContainer/OptionsBtn.grab_focus()


func _on_Btn_mouse_entered():
	$HoverSFX.play()


func _unhandled_input(event):
	if event is InputEventKey:
		if Input.is_action_pressed("ui_cancel") and visible and $Settings.visible == false:
			_on_ResumeBtn_pressed()
			get_tree().get_root().set_input_as_handled()


func _on_Pause_Menu_visibility_changed():
	if visible:
		$PauseCtrl/VBoxContainer/ResumeBtn.grab_focus()
