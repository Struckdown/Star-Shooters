extends Control

signal deploy
signal cancel
var animDir
var buttonsInteractable = false

func _ready():
	updateButtonDisabled(true)
	$AnimationPlayer.playback_speed = 1

func _input(event):
	if event.is_action_pressed("ui_accept"):
		$AnimationPlayer.playback_speed = 4
	if event.is_action_released("ui_accept"):
		$AnimationPlayer.playback_speed = 1



func playDisplayAnimation(dir):
	animDir = dir
	if animDir == "forwards":
		$WindowTexture/SpeechBubble/DialogueLbl.percent_visible = 0
		show()
		#$TypingSFX.play()
		$AnimationPlayer.play("DisplayAnim")
	elif animDir == "backwards":
		$AnimationPlayer.play("HideAnim")
		updateButtonDisabled(true)
	else:
		pass


func updateButtonDisabled(disabled):
	buttonsInteractable = not disabled
	$WindowTexture/OptionsTexture/DeployBtn.disabled = disabled
	$WindowTexture/OptionsTexture/CancelBtn.disabled = disabled

func _on_DeployBtn_visibility_changed():
	pass#$WindowTexture/OptionsTexture/DeployBtn.grab_focus()


func _on_DeployBtn_pressed():
	if buttonsInteractable:
		emit_signal("deploy")
		$ButtonSFX.play()
		updateButtonDisabled(true)


func _on_CancelBtn_pressed():
	if buttonsInteractable:
		emit_signal("cancel")
		$ButtonSFX.play()
		updateButtonDisabled(true)
		playDisplayAnimation("backwards")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "DisplayAnim":
		if animDir == "forwards":
			$WindowTexture/OptionsTexture/DeployBtn.grab_focus()
			updateButtonDisabled(false)
			$TypingSFX.stop()
	if anim_name == "HideAnim":
		hide()

func updateText(planet):
	$WindowTexture/LevelNameLbl.text = planet.missionName
	$WindowTexture/SpeechBubble/DialogueLbl.text = planet.missionBriefing
	$WindowTexture/SpeakerLbl.text = "Commander"#planet.speakerText


func _on_TypingSFX_finished():
	if $WindowTexture/SpeechBubble/DialogueLbl.percent_visible < 1:
		$TypingSFX.play()
