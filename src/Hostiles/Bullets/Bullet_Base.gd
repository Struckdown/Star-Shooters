extends Node2D

var moveSpeed = 200

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var forwardVec = Vector2(1, 0).rotated(rotation).normalized()
	position += forwardVec * moveSpeed * delta


func _on_DespawnTimer_timeout():
	queue_free()
