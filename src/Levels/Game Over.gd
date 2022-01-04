extends Control

signal gameOverAnimationFinished

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Game Over":
		var isBossRush = (GameManager.gameMode == GameManager.gamesModes.BOSSRUSH)
		var isInfiniteMode = (GameManager.gameMode == GameManager.gamesModes.INFINITE)
		var recordScoreOnDefeat = isBossRush or isInfiniteMode
		if recordScoreOnDefeat:
			GameManager.updateStagesCompleted(str(GameManager.stage), GameManager.score)
		if GameManager.stage == "0":
			SceneTransition.transitionToScene("res://Menus/Main Menu.tscn")
		else:
			emit_signal("gameOverAnimationFinished")
			
