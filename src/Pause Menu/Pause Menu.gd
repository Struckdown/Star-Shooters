extends MarginContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _on_ResumeBtn_pressed():
	self.hide()
	get_tree().paused = false


func _on_OptionsBtn_pressed():
	pass # Replace with function body.


func _on_QuitBtn_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://Main Menu.tscn")
