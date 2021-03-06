extends Node2D

# Definitions:
# Volley: All the bullets emitted in a single frame
# Clip size: Amount of bullets that can be fired before the emitter must "reload" (ie a break between a burst of fire)

# Emits bullets in patterns and is meant to be highly configurable
export(int) var rotationDegPerSec = 0	# deg
export(float) var rotationPerVolley = 0 #deg
export(float) var rotationRange = 0	# how many degrees the emitter can rotate before reversing direction, 0 means not used
var rotatingPositively = 1
var internalRotation = 0	# how much the emitter has rotated internally (rad)
var actualRotationStart	# The true relative rotation to parent of the emitter (rad)
export(float) var initialRotationOffset = 0	# Initial offset (deg)
export(String, "straight", "predict", "atTarget") var targetStyle
export(bool) var useRotationAsCenterBullet = false
export(bool) var fireAtLocationForWholeClip = true

export(float) var angleOfBulletSpread = 10	# degrees
export(int) var amountOfBullets = 1
export(int) var volleyClipSize = -1	# -1 for infinite
var volleysRemaining
export(float) var clipReloadTime = 0
export(float) var clipRandomReloadDelay = 0	# seconds
export(int) var bulletMovementSpeed = 10
export(float) var bulletWaveSpeed = 0
export(float) var bulletWaveStr = 0
export(float) var bulletSpawnDelay = 1	# in seconds
export(PackedScene) var bulletType	# must be of class Bullet_Base or child
export(float) var initialSpawnDelayConstant = 0
export(float) var initialSpawnDelayRandomRange = 5	# from 0 to n, adds that amount of seconds randomly offset to initial spawn delay

export(int) var greenBulletFrequency = -1
export(Array, int) var nthBulletIsGreen = []
var volleysFired = 0

export(bool) var emitting = true
export(bool) var DEBUG = false
var target	# what we're trying to track
var positionToShoot	# the actual location we shoot, usually derived from target
var needsToUpdatePosToShoot = true	# assumed to be true initially

var totalDelta = 0	# used for shoot delays. Could use a timer I guess?


signal sweepCompleted	# whenever the turret reverses direction, emit this signal. Two of these would mean a full restart

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	internalRotation = deg2rad(initialRotationOffset)
	actualRotationStart = rotation
	var delay = rand_range(0, initialSpawnDelayRandomRange)
	totalDelta = -initialSpawnDelayConstant - delay
	volleysRemaining = volleyClipSize
	updatePosToShoot()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	totalDelta += delta
	var shouldUpdateRotationPerVolley = false
	if totalDelta > bulletSpawnDelay:
		totalDelta -= bulletSpawnDelay
		if needsToUpdatePosToShoot or targetStyle == "straight":	# could be moving so would always need to update
			updatePosToShoot()
			needsToUpdatePosToShoot = false
		if emitting and volleysRemaining != 0:	# lets this run negative. Is that an issue? Could be if an enemy were to live forever and keep shooting???
			var rad = get_angle_to(positionToShoot)
			spawnBullets(rad)
			volleysRemaining -= 1
		if volleysRemaining == 0:
			totalDelta -= (clipReloadTime + rand_range(0, clipRandomReloadDelay))
			volleysRemaining = volleyClipSize
			needsToUpdatePosToShoot = true
		if not fireAtLocationForWholeClip:
			needsToUpdatePosToShoot = true
		shouldUpdateRotationPerVolley = true
	updateRotation(shouldUpdateRotationPerVolley)

func updatePosToShoot():
	positionToShoot = global_position+global_transform.x
	if not is_instance_valid(target):	# tries to find the player
		if len(get_tree().get_nodes_in_group("Player")) > 0:
			target = get_tree().get_nodes_in_group("Player")[0]
		else:
			return	# just return and shoot straight forward
	match targetStyle:
		"straight":
			positionToShoot = global_position+global_transform.x
		"predict":
			positionToShoot = getExpectedTargetPosition()
		"atTarget":
			positionToShoot = target.global_position
		_:
			positionToShoot = global_position+global_transform.x

# Additional rads is how much to rotate the fire arc by (in rads)
func spawnBullets(additionalRads):
	$FireSFX.play()
	for i in range(amountOfBullets):
		var b = bulletType.instance()
		if i in nthBulletIsGreen and volleysFired%greenBulletFrequency == 0:
			b.setGeneratesEnergy(true)
		get_viewport().add_child(b)
		b.global_position = global_position
		b.global_rotation = global_rotation + additionalRads
		
		# Calculate additional offset for shooting more than 1 bullet
		var j
		if useRotationAsCenterBullet:
			j = (i%2) * 2 - 1	# j is either -1 or 1
			if amountOfBullets % 2 == 0:	#bullet num is even
				var ang = ceil(float(i+1)/2.0)*angleOfBulletSpread - angleOfBulletSpread*0.5
				var addedRot = (deg2rad(ang*j) / 2.0)
				b.global_rotation += addedRot
			else:	#bullet num is odd
				var addedRot = deg2rad(ceil(float(i)/2.0)*angleOfBulletSpread*j)
				b.global_rotation += addedRot
		else:
			b.global_rotation += deg2rad(i*angleOfBulletSpread)
		b.moveSpeed = bulletMovementSpeed
		b.waveSpeed = bulletWaveSpeed
		b.waveStr = bulletWaveStr
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

