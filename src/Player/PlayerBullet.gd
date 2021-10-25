extends Node2D

var moveSpeed = 800
export(PackedScene) var explosion

# Called when the node enters the scene tree for the first time.
func _ready():
	var animStartPoint = rand_range(0, 0.2)
	$AnimationPlayer.seek(animStartPoint)
	var startFrame = rand_range(0, 2)
	$Sprite.frame = startFrame


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.y += delta * moveSpeed * -1


# Destroy the bullet by playing a particle effect
func destroy():
	var e = explosion.instance()
	get_parent().add_child(e)
	e.global_position = global_position
	var randomOffset = Vector2(rand_range(-5, 5), rand_range(0, -25))
	e.position += randomOffset
	e.emitting = true
	queue_free()
	


func _on_DespawnTimer_timeout():
	queue_free()


func _on_Area2D_area_entered(area):
	if area.is_in_group("Enemy"):
		var areaOwner = area.owner
		if is_instance_valid(areaOwner) and areaOwner.has_method("applyDamage"):
			areaOwner.applyDamage()
			destroy()
