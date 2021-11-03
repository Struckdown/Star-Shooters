extends RigidBody2D

var speed = 100
var velocity = Vector2(1,0)
var canCauseDamage = true
export(int) var piecesWhenBrokenMin = 0
export(int) var piecesWhenBrokenMax = 3
var piecesWhenBroken
var asteroid = load("res://Hostiles/Enemies/Asteroid.tscn")
var splitting = false
export(int) var health = 1
var loadedGem = preload("res://Hostiles/GemSpawner.tscn")
var initialHealth = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	initialHealth = health
	var rotationSpeedMultiplier = rand_range(0.5, 2.5)
	$AnimationPlayer.playback_speed = rotationSpeedMultiplier
	var d = piecesWhenBrokenMax - piecesWhenBrokenMin + 1
	if d > 0:
		piecesWhenBroken = randi() % d + piecesWhenBrokenMin
	else:
		piecesWhenBroken = max(0, piecesWhenBrokenMax)

func init():
	linear_velocity = (velocity*speed*GameManager.gameSpeed).rotated(rotation)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
#	move(delta)

#func move(delta):
#	#var collision = move_and_collide(velocity*delta*speed)
#	if collision:
#		velocity += collision.normal * 0.7
#		var otherObj = collision.collider
#		otherObj.velocity = otherObj.velocity + collision.normal * -0.7


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


func applyDamage(damage):
	health -= damage
	if health <= 0:
		if not splitting:
			splitting = true
			splitApart()
			spawnGems()

func splitApart():
	for _i in range(piecesWhenBroken):
		var a = asteroid.instance()
		get_viewport().call_deferred("add_child", a)
		a.global_position = global_position
		a.rotation_degrees = rand_range(0, 360)
		a.speed = rand_range(250, 370) * GameManager.gameSpeed
		a.init()
	var partsParticles = load("res://Explosions/PartsEmitter.tscn").instance()
	get_viewport().add_child(partsParticles)
	partsParticles.global_position = global_position
	partsParticles.emitting = true
	queue_free()

func spawnGems():
	var g = loadedGem.instance()
	g.gemsRemaining = initialHealth * (randi()%2+2)
	g.global_position = global_position
	get_viewport().call_deferred("add_child", g)

