extends Node2D

var moveSpeed = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var forwardVec = Vector2(0,-1).rotated(rotation).normalized()
	position += forwardVec * moveSpeed * delta
