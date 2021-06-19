extends Node

signal deploy
signal cancel
var animDir
var fullyVisible = false

func _ready():
	pass


func playDisplayAnimation(forwards):
	animDir = forwards
	if animDir == "forwards":
		$WindowTexture.show()
		$AnimationPlayer.play("DisplayAnim")
	elif animDir == "backwards":
		$AnimationPlayer.play_backwards("DisplayAnim")
	else:
		pass


func _on_DeployBtn_visibility_changed():
	$WindowTexture/OptionsTexture/DeployBtn.grab_focus()


func _on_DeployBtn_pressed():
	if fullyVisible:
		emit_signal("deploy")
		fullyVisible = false


func _on_CancelBtn_pressed():
	if fullyVisible:
		emit_signal("cancel")
		fullyVisible = false
		playDisplayAnimation("backwards")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "DisplayAnim":
		if animDir == "backwards":
			$WindowTexture.hide()
			fullyVisible = false
		if animDir == "forwards":
			fullyVisible = true
		
