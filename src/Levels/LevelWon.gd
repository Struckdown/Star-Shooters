extends Control

signal levelWon

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func playLevelComplete():
	$AnimationPlayer.play("Level Won")
	$AudioStreamPlayer.play()
	emit_signal("levelWon")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Level Won":
		GameManager.updateScores(GameManager.score)
		if GameManager.stage == 0:
			SceneTransition.transitionToScene("res://Menus/Main Menu.tscn")
		else:
			SceneTransition.transitionToScene("res://Levels/LevelSelect/LevelSelect.tscn")
