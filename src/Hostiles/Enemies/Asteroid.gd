extends KinematicBody2D

var speed = 100
var velocity = Vector2(1,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	var rotationSpeedMultiplier = rand_range(0.5, 2.5)
	$AnimationPlayer.playback_speed = rotationSpeedMultiplier



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move(delta)

func move(delta):
	var collision = move_and_collide(velocity*delta*speed)
	if collision:
		velocity += collision.normal * 0.7
		var otherObj = collision.collider
		otherObj.velocity = otherObj.velocity + collision.normal * -0.7


func setUpSize():	# TODO the hitbox doesn't work for larger asteroids >:(
	var possibleSprites = {
		"large":{
			"weight": 1,
			"speedMultiplier": 0.5,
			"sprites": [
				"res://Space Shooter Redux/PNG/Meteors/meteorBrown_big1.png",
				"res://Space Shooter Redux/PNG/Meteors/meteorBrown_big2.png",
				"res://Space Shooter Redux/PNG/Meteors/meteorBrown_big3.png",
				"res://Space Shooter Redux/PNG/Meteors/meteorBrown_big4.png",
			]
		},
		"med":{
			"weight": 2,
			"sprites": [
				"res://Space Shooter Redux/PNG/Meteors/meteorBrown_med1.png",
				"res://Space Shooter Redux/PNG/Meteors/meteorBrown_med3.png"
			]
		},
		"small":{
			"weight": 4,
			"sprites": [
				"res://Space Shooter Redux/PNG/Meteors/meteorBrown_small1.png",
				"res://Space Shooter Redux/PNG/Meteors/meteorBrown_small2.png",
				"res://Space Shooter Redux/PNG/Meteors/meteorBrown_tiny1.png",
				"res://Space Shooter Redux/PNG/Meteors/meteorBrown_tiny2.png",
			]
		}
	}
	randomize()
	var totalWeights = 0
	for i in possibleSprites:
		totalWeights += possibleSprites[i]["weight"]
	var pick = randi()%totalWeights
	var sprite = null
	var runningTotal = 0
	for i in possibleSprites:
		if possibleSprites[i]["weight"] + runningTotal >= pick:
			var j = randi()%len(possibleSprites[i]["sprites"])
			sprite = possibleSprites[i]["sprites"][j]
			break
		runningTotal += possibleSprites[i]["weight"]
	$Sprite.texture = load(sprite)
	var newArea = $Area2D/CollisionShape2D.shape.duplicate()
	#$Area2D/CollisionShape2D.queue_free()
	$Area2D/CollisionShape2D.shape = newArea
	newArea.extents = $Sprite.texture.get_size() * 0.5
	print(newArea)
