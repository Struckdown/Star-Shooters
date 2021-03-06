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
	emit_signal("levelWon")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Level Won":
		GameManager.updateScores(GameManager.score)
		SceneTransition.transitionToScene("res://Levels/LevelSelect/LevelSelect.tscn")
