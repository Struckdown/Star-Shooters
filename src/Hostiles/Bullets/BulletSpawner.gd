extends Node2D


var rate


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func spawnBullet():
	var b = load("res://Hostiles/Bullets/Bullet_Base.tscn")
	var bInst = b.instance()
	var boxSize = $Area2D/CollisionShape2D.shape.extents * scale * 2
	get_parent().add_child(bInst)
	bInst.position = ((pickRandomPointInRec(position, boxSize)-position).rotated(rotation)+position)
	bInst.rotation = rotation

# Given a world pos (center of box), and box size, pick a random point in it
func pickRandomPointInRec(pos, size):
	var pos_x = size.x * randf() - size.x/2
	var pos_y = size.y * randf() - size.y/2
	pos_x += pos.x
	pos_y += pos.y
	return Vector2(pos_x,pos_y)


func _on_Timer_timeout():
	spawnBullet()
