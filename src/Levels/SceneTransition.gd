extends Control

signal fadeFinished
var fadedToBlack = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func fadeinFromBlack():
	$AnimationPlayer.play("FadeInFromBlack")
	fadedToBlack = false

func fadetoBlack():
	$AnimationPlayer.play_backwards("FadeInFromBlack")
	fadedToBlack = true


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name in ["FadeInFromBlack"]:
		emit_signal("fadeFinished")
	else:
		raise()
