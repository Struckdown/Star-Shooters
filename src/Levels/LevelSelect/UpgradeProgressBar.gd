extends Control
tool

export(float, 0, 1) var fractionFull = 0 setget updateFraction

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func updateFraction(newFrac):
	fractionFull = clamp(newFrac, 0, 1)
	if has_node("Pips"):
		$Pips.rect_size.x = (fractionFull*$Background.rect_size.x-25)
