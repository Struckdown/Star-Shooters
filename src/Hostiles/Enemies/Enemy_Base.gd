extends Node2D


var speed = 100
signal destroyed

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += Vector2(0, delta*speed).rotated(rotation)


#Called when the enemy is destroyed
func _exit_tree():
	emit_signal("destroyed")


func _on_Timer_timeout():
	queue_free()
