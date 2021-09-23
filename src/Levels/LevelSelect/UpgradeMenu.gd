extends Control

var displaying = false
onready var activeArrows = [$WindowTexture/DownArrow, $WindowTexture/UpArrow]

signal shopClosed

# Called when the node enters the scene tree for the first time.
func _ready():
	startFlashingArrowTween()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	updateArrows()

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

func startFlashingArrowTween():
	for arrow in activeArrows: 
		$Tween.interpolate_property(arrow, "modulate", Color(1, 1, 1, arrow.modulate.a), Color(1, 1, 1, 0), 1, Tween.TRANS_SINE)
		$Tween.interpolate_property(arrow, "modulate", Color(1, 1, 1, arrow.modulate.a), Color(1, 1, 1, 0), 1, Tween.TRANS_SINE)
	$Tween.start()


func _on_Tween_tween_completed(object, _key):
	if object in activeArrows:
		var targetAlpha = 1-object.modulate.a
		$Tween.interpolate_property(object, "modulate", Color(1, 1, 1, object.modulate.a), Color(1, 1, 1, targetAlpha), 1, Tween.TRANS_SINE)
	else:
		$Tween.interpolate_property(object, "modulate", Color(1, 1, 1, object.modulate.a), Color(1, 1, 1, 0), 1, Tween.TRANS_SINE)
	$Tween.start()


func updateArrows():
	activeArrows = [$WindowTexture/UpArrow, $WindowTexture/DownArrow]
	if $WindowTexture/ScrollContainer.scroll_vertical >= 107:	# at the bottom
		activeArrows.remove(1)
	if $WindowTexture/ScrollContainer.scroll_vertical <= 0:
		activeArrows.remove(0)
