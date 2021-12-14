extends Node2D

var readyToAdvance = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if event is InputEventKey and not event.is_pressed() and readyToAdvance:
		$Credits.display(true)

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"revealSidedWithCommander":
			$AnimationPlayer.play("pressAnyKey")
			readyToAdvance = true
		"revealSidedWithFederation":
			$AnimationPlayer.play("pressAnyKey")
			readyToAdvance = true


func _on_Timer_timeout():
	match GameManager.endingToPlay:
		"federationVictory":
			$AnimationPlayer.play("revealSidedWithFederation")
		"commanderVictory":
			$AnimationPlayer.play("revealSidedWithCommander")


func _on_Credits_closed():
	if $Credits.visible:
		SceneTransition.transitionToScene("res://Menus/Main Menu.tscn")
