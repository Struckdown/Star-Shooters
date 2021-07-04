extends Node2D

var speed = 100
var direction = Vector2(1,1)
var rotSpeed
var dragCoefficient = 0.9
var velocity

var magnetSpeed = 300
var playerRef

# Called when the node enters the scene tree for the first time.
func _ready():
	init()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if playerRef:
		var dir = position.direction_to(playerRef.position).normalized()
		position += dir*delta*magnetSpeed
	else:
		velocity = velocity-(dragCoefficient*velocity*delta)
		position += velocity*delta

	rotation_degrees += rotSpeed*delta

func init():
	randomize()
	var x = rand_range(-1, 1)
	var y = rand_range(-1, 1)
	speed = rand_range(100, 150)
	direction = Vector2(x, y).normalized()
	velocity = speed*direction
	
	rotSpeed = rand_range(-360,360)

func collect():
	queue_free()


func _on_Timer_timeout():
	$DespawnAnimationPlayer.play("Despawning")


func _on_DespawnAnimationPlayer_animation_finished(anim_name):
	queue_free()
