extends MarginContainer


var hints = [
	"Any gems acquired can be spent at the asteroid upgrade store to permanently strengthen your ship!",
	"You can adjust the game speed in the settings if you're struggling!",
]
signal retry
signal backToMap

# Called when the node enters the scene tree for the first time.
func _ready():
	randomlyPickHint()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func randomlyPickHint():
	randomize()
	var finalString = "Hint: "
	var hintIndex = randi() % len(hints)
	finalString += hints[hintIndex]
	$RetryCtrl/RetryHint.text = finalString

func _on_RetryBtn_pressed():
	emit_signal("retry")
	$ClickSFX.play()


func _on_QuitBtn_pressed():
	emit_signal("backToMap")
	$ClickSFX.play()


func _on_RetryBtn_mouse_entered():
	$HoverSFX.play()

func display():
	$AnimationPlayer.play("Show")


func _on_AnimationPlayer_animation_finished(_anim_name):
	$RetryCtrl/HBoxContainer/RetryBtn.grab_focus()
