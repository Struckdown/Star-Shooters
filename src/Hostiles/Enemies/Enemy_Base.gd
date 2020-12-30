extends Node2D


var speed = 100
signal destroyed

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move(delta)


#Called when the enemy is destroyed
func _exit_tree():
	emit_signal("destroyed")


func move(d):
	position += Vector2(d*speed, 0).rotated(rotation)
