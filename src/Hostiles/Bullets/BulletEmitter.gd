extends Node2D

# Emits bullets in patterns and is meant to be highly configurable
export(int) var rotationDegPerSec = 0	# deg
export(float) var rotationPerVolley = 0 #deg
export(float) var rotationRange = 0	# how many degrees the emitter can rotate before reversing direction, 0 means not used
var rotatingPositively = 1
var internalRotation = 0	# how much the emitter has rotated internally (rad)
var actualRotationStart	# The true relative rotation to parent of the emitter (rad)
export(float) var initialRotationOffset = 0	# Initial offset (deg)

export(int) var angleOfBulletSpread = 10	# degrees
export(int) var amountOfBullets = 1
export(int) var bulletMovementSpeed = 10
export(float) var bulletSpawnDelay = 1	# in seconds
export(PackedScene) var bulletType	# must be of class Bullet_Base or child

var totalDelta = 0	# used for shoot delays. Could use a timer I guess?

signal sweepCompleted	# whenever the turret reverses direction, emit this signal. Two of these would mean a full restart

# Called when the node enters the scene tree for the first time.
func _ready():
	internalRotation = initialRotationOffset
	actualRotationStart = rotation


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	totalDelta += delta
	if totalDelta > bulletSpawnDelay:
		totalDelta -= bulletSpawnDelay
		spawnBullets()
		updateRotation(true)
	updateRotation(false)

func spawnBullets():
	for i in range(amountOfBullets):
		var b = bulletType.instance()
		get_viewport().add_child(b)
#		get_parent().add_child(b)
		b.global_position = global_position
		b.global_rotation = global_rotation + deg2rad(i*angleOfBulletSpread)
		b.moveSpeed = bulletMovementSpeed

func updateRotation(volleyUpdate):
	var amountToRotate = 0
	if volleyUpdate:
		amountToRotate += rotationPerVolley
	amountToRotate += rotationDegPerSec

	if rotationRange != 0:
		if rotatingPositively > 0:
			if (amountToRotate + rad2deg(internalRotation)) > rotationRange:
				amountToRotate = rotationRange-rad2deg(internalRotation)
		else:
			if (rad2deg(internalRotation) - amountToRotate < 0):
				amountToRotate = rad2deg(internalRotation)

	internalRotation += deg2rad(amountToRotate * rotatingPositively)

	if rotationRange != 0:
		if rotationRange - rad2deg(internalRotation) <= 0.0001:
			if rotatingPositively == 1:
				rotatingPositively = -1
				emit_signal("sweepCompleted")
		elif rad2deg(internalRotation) <= 0:
			if rotatingPositively == -1:
				rotatingPositively = 1
				emit_signal("sweepCompleted")
		else:
			pass
	
	rotation = actualRotationStart + internalRotation
