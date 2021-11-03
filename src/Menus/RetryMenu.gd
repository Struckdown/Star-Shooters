extends MarginContainer


var hints = [
	"Any gems acquired can be spent at the asteroid upgrade store to permanently strengthen your ship.",
	"You can adjust the game speed in the settings if you're struggling!",
	"Most enemies have no randomness in their attack patterns, so pay close attention to safe places.",
	"So long as you have enough charge (the white bar), you can survive a direct hit.",
	"Wrapping around the sides of the screen can get you out of tricky places. Some enemies may require it.",
	"Don't give up! You're braver than you believe, stronger than you seem and smarter than you think!",
	"Increasing your max energy cap doesn't change how many direct hits you can take. Just how much you can attack.",
	"It can be worthwhile to bank a bit of energy before moving onto the next wave.",
	"Game too easy (and yet you're here)? Up the difficulty with insta-kill mode in the settings. One hit, you're dead!"
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
