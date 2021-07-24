extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Game Over":
		if GameManager.stage == 0:
			SceneTransition.transitionToScene("res://Menus/Main Menu.tscn")
		else:
			SceneTransition.transitionToScene("res://Levels/LevelSelect/LevelSelect.tscn")
