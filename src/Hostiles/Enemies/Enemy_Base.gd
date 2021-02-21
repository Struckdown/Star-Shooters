extends Node2D

var pointsWorth = 100
var speed = 0
var health = 50
signal destroyed
export(PackedScene) var explosionType
var explosionParticles

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move(delta)


#Called when the enemy is destroyed
func _exit_tree():
	emit_signal("destroyed", pointsWorth)


func move(d):
	position += Vector2(d*speed, 0).rotated(rotation)


func destroy():
	explosionParticles = explosionType.instance()
	add_child(explosionParticles)
	$AnimationPlayer.play("Death")
	explosionParticles.emitting = true
	$ExplosionTimer.start()


func _on_ExplosionTimer_timeout():
	remove_child(explosionParticles)
	get_parent().add_child(explosionParticles)
	queue_free()


func _on_Area2D_area_entered(area):
	if area.is_in_group("PlayerBullet"):
		if health > 0:
			health -= 1
			area.owner.destroy()
			if health <= 0:
				destroy()
