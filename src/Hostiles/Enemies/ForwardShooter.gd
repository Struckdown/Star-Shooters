extends "res://Hostiles/Enemies/Enemy_Base.gd"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	position += Vector2(0, delta*speed).rotated(rotation)


##Called when the enemy is destroyed
#func _exit_tree():
#	emit_signal("destroyed")


func _on_ShotTimer_timeout():
	spawnBullet()

func spawnBullet():
	var b = load("res://Hostiles/Bullets/Bullet_Base.tscn")
	b = b.instance()
	get_parent().add_child(b)
	b.position = position
	var fwdVec = transform.x * 10
	b.position += fwdVec
	b.rotation = rotation
