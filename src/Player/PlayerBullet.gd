extends Node2D

var moveSpeed = 800

# Called when the node enters the scene tree for the first time.
func _ready():
	var startPoint = rand_range(0, 0.2)
	$AnimationPlayer.seek(startPoint)
	var startFrame = rand_range(0, 2)
	$Sprite.frame = startFrame


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.y += delta * moveSpeed * -1
