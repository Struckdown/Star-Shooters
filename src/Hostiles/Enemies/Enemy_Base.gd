extends Node2D


var speed = 0
var health = 10
signal destroyed
export(PackedScene) var explosionType


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


func destroy():
	var particles = explosionType.instance()
	add_child(particles)
	particles.emitting = true
	$ExplosionTimer.start()


func _on_ExplosionTimer_timeout():
	queue_free()


func _on_Area2D_area_entered(area):
	if area.is_in_group("PlayerBullet"):
		health -= 1
		area.owner.queue_free()
		if health <= 10:
			destroy()
