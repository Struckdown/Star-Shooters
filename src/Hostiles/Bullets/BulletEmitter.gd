extends Node2D

# Emits bullets in patterns and is meant to be highly configurable
export(int) var rotationDegPerSec = 0	# deg
export(float) var rotationPerVolley = 0 #deg
export(float) var rotationRange = 0	# how many degrees the emitter can rotate before reversing direction, 0 means not used
var rotatingPositively = 1
var internalRotation = 0	# how much the emitter has rotated internally (rad)
var actualRotationStart	# The true relative rotation to parent of the emitter (rad)
export(float) var initialRotationOffset = 0	# Initial offset (deg)
export(String, "straight", "predict", "atTarget") var targetStyle


export(int) var angleOfBulletSpread = 10	# degrees
export(int) var amountOfBullets = 1
export(int) var bulletMovementSpeed = 10
export(float) var bulletSpawnDelay = 1	# in seconds
export(PackedScene) var bulletType	# must be of class Bullet_Base or child
export(float) var initialSpawnDelayConstant = 0
export(float) var initialSpawnDelayRandomRange = 5	# from 0 to n, adds that amount of seconds randomly offset to initial spawn delay

export(int) var greenBulletFrequency = -1
export(Array, int) var nthBulletIsGreen = []
var volleysFired = 0

export(bool) var emitting = true
var target

var totalDelta = 0	# used for shoot delays. Could use a timer I guess?


signal sweepCompleted	# whenever the turret reverses direction, emit this signal. Two of these would mean a full restart

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	internalRotation = deg2rad(initialRotationOffset)
	actualRotationStart = rotation
	var delay = rand_range(0, initialSpawnDelayRandomRange)
	totalDelta = -initialSpawnDelayConstant - delay



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	totalDelta += delta
	if totalDelta > bulletSpawnDelay:
		totalDelta -= bulletSpawnDelay
		if emitting:
			spawnBullets()
		updateRotation(true)
	updateRotation(false)

func spawnBullets():
	var additionalRads

	match targetStyle:
		"straight":
			additionalRads = 0
		"predict":
			additionalRads = 0
			if len(get_tree().get_nodes_in_group("Player")) > 0:
				target = get_tree().get_nodes_in_group("Player")[0]
				additionalRads = get_angle_to(getExpectedTargetPosition())
		"atTarget":
			if len(get_tree().get_nodes_in_group("Player")) > 0:
				target = get_tree().get_nodes_in_group("Player")[0].global_position
				additionalRads = get_angle_to(target)
		_:
			additionalRads = 0
	for i in range(amountOfBullets):
		var b = bulletType.instance()
		if i in nthBulletIsGreen and volleysFired%greenBulletFrequency == 0:
			b.setGeneratesEnergy(true)
		get_viewport().add_child(b)
		b.global_position = global_position
		b.global_rotation = global_rotation + deg2rad(i*angleOfBulletSpread) + additionalRads
		b.moveSpeed = bulletMovementSpeed
	volleysFired += 1

# volleyUpdate is a bool whether to increase rotation per volley shot
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

func toggleEmitting(state):
	for child in get_children():
		if child.has_method("toggleEmitting"):
			child.toggleEmitting(state)
	if state != null:
		emitting = state
	else:
		emitting = !emitting


# Solving circle line intersect problem using quadratic formula
# Consider y = tx+b as the line that identifies the player's position, and a circle of the equation x*x + y*y = t (t is time and the radius of the circle)
func getExpectedTargetPosition():
	# assume our position to be origin (0,0)
	var x = target.global_position.x - global_position.x	# target position relative to ours
	var y = target.global_position.y - global_position.y
	var v = bulletMovementSpeed
	var tx = target.velocity.x# target velocity
	var ty = target.velocity.y #

	# achieved by substituting equations to get (a)t*t + (b)t + (c) quadratic formula and then solving
	var a = tx*tx + ty*ty - v*v	#delta change in distance
	var b = (2*x*tx) + (2*y*ty)
	var c = x*x + y*y	# defines a circle

	var sqrtVal = b*b - 4*a*c	# aka the determinant of the quadratic equation
	if sqrtVal <= 0 or a == 0:
		print("Returned impossible situation, shooting cur pos")
		return target.global_position
	sqrtVal = sqrt(sqrtVal)
	
	var t1 = (-b + sqrtVal)/(2*a)
	var t2 = (-b - sqrtVal)/(2*a)

	var time
	if t1 >=0 and t2 >= 0:	# grab smaller of two values, selecting the one greater than 0.
		time = min(t1, t2)
	elif t1 >= 0:
		time = t1
	elif t2 >= 0:
		time = t2
	else:
		time = 0
	time = min(3, time)	# Upperbound time at 3 seconds
	
	var predictedPosition = target.global_position + target.velocity*time

	return predictedPosition

