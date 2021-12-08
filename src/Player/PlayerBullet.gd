extends Node2D

var moveSpeed = 800
var damage = 1
var explosionManagerRef
export(PackedScene) var explosion

# Called when the node enters the scene tree for the first time.
func _ready():
	var animStartPoint = rand_range(0, 0.2)
	$AnimationPlayer.seek(animStartPoint)
	var startFrame = rand_range(0, 2)
	$Sprite.frame = startFrame


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move(delta)
	if not inBounds():
		queue_free()
	

func move(delta):
	var forwardVec = Vector2(1, 0).rotated(rotation).normalized()
	position += forwardVec * moveSpeed * delta	# forward motion

# Destroy the bullet by playing a particle effect
func destroy():
	if explosionManagerRef:
		var pos = position
		var randomOffset = Vector2(rand_range(-5, 5), rand_range(0, -25))
		pos += randomOffset
		explosionManagerRef.requestExplosion("single", pos)
	queue_free()
	


func _on_DespawnTimer_timeout():
	queue_free()


func _on_Area2D_area_entered(area):
	if area.is_in_group("Enemy"):
		var areaOwner = area.owner
		if is_instance_valid(areaOwner) and areaOwner.has_method("applyDamage"):
			areaOwner.applyDamage(damage)
			destroy()

func inBounds() -> bool:
	if position.y < -5:
		return false
	return true
