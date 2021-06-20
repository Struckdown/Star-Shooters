extends Control

signal deploy
signal cancel
var animDir
var buttonsInteractable = false

func _ready():
	buttonsInteractable = visible


func playDisplayAnimation(dir):
	animDir = dir
	if animDir == "forwards":
		show()
		$AnimationPlayer.play("DisplayAnim")
	elif animDir == "backwards":
		$AnimationPlayer.play("HideAnim")
		buttonsInteractable = false
	else:
		pass


func _on_DeployBtn_visibility_changed():
	pass#$WindowTexture/OptionsTexture/DeployBtn.grab_focus()


func _on_DeployBtn_pressed():
	if buttonsInteractable:
		print("event triggered in briefing")
		emit_signal("deploy")
		buttonsInteractable = false


func _on_CancelBtn_pressed():
	if buttonsInteractable:
		emit_signal("cancel")
		buttonsInteractable = false
		playDisplayAnimation("backwards")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "DisplayAnim":
		if animDir == "forwards":
			$WindowTexture/OptionsTexture/DeployBtn.grab_focus()
			buttonsInteractable = true
	if anim_name == "HideAnim":
		hide()
