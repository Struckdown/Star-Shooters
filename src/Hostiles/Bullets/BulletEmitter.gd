extends Node2D

# Emits bullets in patterns and is meant to be highly configurable
export(int) var rotationDegPerSec = 2
export(int) var angleOfBulletSpread = 10	# degrees
export(int) var amountOfBullets = 1
export(int) var bulletMovementSpeed = 10
export(float) var bulletSpawnDelay = 1	# in seconds
export(PackedScene) var bulletType	# must be of class Bullet_Base or child

var totalDelta = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	totalDelta += delta
	if totalDelta > bulletSpawnDelay:
		totalDelta -= bulletSpawnDelay
		spawnBullets()
	rotation += deg2rad(rotationDegPerSec)

func spawnBullets():
	transform.x
	for i in range(amountOfBullets):
		var b = bulletType.instance()
		get_parent().add_child(b)
		b.position = position
		b.rotation = rotation + deg2rad(i*angleOfBulletSpread)
		b.moveSpeed = bulletMovementSpeed
