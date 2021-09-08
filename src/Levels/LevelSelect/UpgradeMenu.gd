extends Control

var displaying = false

signal shopClosed

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func display(shouldDisplay):
	if displaying == shouldDisplay:
		return
	displaying = shouldDisplay
	if shouldDisplay:
		$AnimationPlayer.play("Display")
	else:
		$AnimationPlayer.play_backwards("Display")

func _on_CloseButton_button_up():
	display(false)
	$WindowTexture/CloseButton/CloseSFX.play()
	emit_signal("shopClosed")
	$WindowTexture/CloseButton.release_focus()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Display" and displaying:
		$WindowTexture/ScrollContainer/VBoxContainer/StartChargeUpgrade/Button.grab_focus()
