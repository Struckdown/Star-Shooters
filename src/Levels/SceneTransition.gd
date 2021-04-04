extends Control

signal fadeFinished
var nextScenePath

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func transitionToScene(_nextScenePath):
	nextScenePath = _nextScenePath
	fadetoBlack()

func fadeinFromBlack():
	$AnimationPlayer.play("FadeInFromBlack")

func fadetoBlack():
	$AnimationPlayer.play("FadeToBlack")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name in ["FadeInFromBlack", "FadeToBlack"]:
		emit_signal("fadeFinished")
		if anim_name == "FadeToBlack":
			if nextScenePath:
				var err = get_tree().change_scene(nextScenePath)
				if !err:
					fadeinFromBlack()
	else:
		raise()
