extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func display(shouldDisplay):
	if shouldDisplay:
		$AnimationPlayer.play("Display")
	else:
		$AnimationPlayer.play_backwards("Display")


func _on_TextureButton_pressed():
	display(false)
