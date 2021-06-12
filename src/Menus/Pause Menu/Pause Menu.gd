extends MarginContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	$Settings.connect("closed", self, "hideSettings")

func _on_ResumeBtn_pressed():
	self.hide()
	get_tree().paused = false


func _on_OptionsBtn_pressed():
	$Settings.show()
	$ClickSFX.play()


func _on_QuitBtn_pressed():
	$ClickSFX.play()
	get_tree().paused = false
	if(get_tree().change_scene("res://Menus/Main Menu.tscn")):
		print("ERROR in screen change!")

func hideSettings():
	$ClickSFX.play()
	$Settings.hide()


func _on_Btn_mouse_entered():
	$HoverSFX.play()


func _unhandled_input(event):
	if event is InputEventKey:
		if Input.is_action_pressed("ui_cancel") and visible and $Settings.visible == false:
			_on_ResumeBtn_pressed()
			get_tree().get_root().set_input_as_handled()
