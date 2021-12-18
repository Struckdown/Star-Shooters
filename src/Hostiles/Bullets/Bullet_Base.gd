extends Node2D

var lifetime := 10.0
var dying = false
export(int) var moveSpeed = 200
export(int) var waveStr = 0
onready var startTime = OS.get_ticks_msec()
var elapsedTime = 0.0
var horizontalOffset = 0
var prevHorizontalOffset = 0
export(float) var waveSpeed = 10
export(bool) var generatesEnergy = false
export(String, FILE) var energySprite
var totalHOffset = 0
export(bool) var titleScreenVersion
export(float) var rotationSpeed = 0
var originalScale = Vector2(1,1)	# given by parent
export(CurveTexture) var bulletScaleCurve
export(NodePath) var nodeToRotate
var orbitalChildren = -1	# used by rotationalBullet
var orbitalRotationSpeedDegs = 0
export(bool) var trackYFirst = false	# orthogonal bullets
export(bool) var canCauseDamage = true
export(bool) var diesOnOutOfBounds = true
var targetPos = null
var target = null	# used in derived classes
var bounds
var wrapsRemaining = 0
var hasEverBeenInBounds = false
var bouncesRemaining = 0
var directionVectorMultiplier = Vector2(1, 1)	# used for bounces
var energyAmountToGenerate = 25.0

# Called when the node enters the scene tree for the first time.
func _ready():
	if generatesEnergy:
		setGeneratesEnergy(true)
	if titleScreenVersion:
		dying = true	# hack that avoids the fadeout ever being called
	if nodeToRotate and typeof(nodeToRotate) != TYPE_OBJECT:
		nodeToRotate = get_node(nodeToRotate)
	bounds = get_viewport_rect().size
	bounds.x *= 0.8

func init():
	pass	# overridden in children classes

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move(delta*GameManager.gameSpeed)
	updateNodeToRotate(delta)
	checkHasEverBeenInBounds()
	var bounced = checkForBounce()
	if not bounced:
		checkForWrap()
	checkForEndOfLife()
	updateScale()


func startFadeOut():
	var initColor = modulate
	var finalColor = initColor
	finalColor[3] = 0
	$EndOfLifeTween.interpolate_property(self, "modulate", initColor, finalColor, 0.3)
	$EndOfLifeTween.start()

func setGeneratesEnergy(generates):
	var area = $Area2D
	if not generates and area.is_in_group("generatesEnergy"):
		area.remove_from_group("generatesEnergy")
	if generates and not area.is_in_group("generatesEnergy"):
		area.add_to_group("generatesEnergy")
		changeEnergySprite()

func changeEnergySprite():
	if energySprite:
		get_node("Sprite").texture = load(energySprite)


func move(delta):
	var forwardVec = Vector2(1, 0).rotated(rotation).normalized()
	forwardVec.x *= directionVectorMultiplier.x
	forwardVec.y *= directionVectorMultiplier.y
	if targetPos != null:
		if global_position.distance_squared_to(targetPos) >= 16:
			forwardVec = (targetPos-global_position).normalized()
		else:
			moveSpeed = 0
			global_position = targetPos

	var sideVec = transform.y
	elapsedTime += delta #(OS.get_ticks_msec() - startTime) * 0.001	# convert to seconds
	horizontalOffset = sin(elapsedTime*waveSpeed+PI/2) * waveStr
	totalHOffset += (horizontalOffset - prevHorizontalOffset)
	sideVec *= totalHOffset

	position += forwardVec * moveSpeed * delta	# forward motion
	position += sideVec * delta	# side wiggle
	prevHorizontalOffset = horizontalOffset

func updateNodeToRotate(delta):
	if nodeToRotate:
		nodeToRotate.rotate(deg2rad(rotationSpeed)*delta)

func markEnergyDrained():
	if $Area2D.is_in_group("generatesEnergy"):
		$Area2D.remove_from_group("generatesEnergy")
		modulate = modulate*0.8


func _on_EndOfLifeTween_tween_completed(_object, _key):
	queue_free()


func checkForWrap():
	if outOfBounds():
		if wrapsRemaining <= 0:
			var abovePlaySpace = global_position.y < 0
			if not titleScreenVersion and diesOnOutOfBounds and not abovePlaySpace:
				startFadeOut()
		else:
			var _wrapped = wrap()

# check if out of bounds for wrapping
func outOfBounds() -> bool:
	if global_position.x > bounds.x:
		return true
	if global_position.x < 0:
		return true
	if global_position.y < 0:
		return true
	if global_position.y > bounds.y:
		return true
	return false
	
func wrap() -> bool:
	var wrapped = false
	wrapsRemaining -= 1
	if global_position.x > bounds.x:
		position.x -= bounds.x
		wrapped = true
	if global_position.x < 0:
		position.x += bounds.x
		wrapped = true
	if global_position.y < 0:
		position.y += bounds.y
		wrapped = true
	if global_position.y > bounds.y:
		position.y -= bounds.y
		wrapped = true
	return wrapped


func checkForBounce() -> bool:
	var bounced = false
	if outOfBounds():
		if bouncesRemaining > 0:
			bouncesRemaining -= 1
			if position.x > bounds.x:
				directionVectorMultiplier.x *= -1
				bounced = true
			if position.x < 0:
				directionVectorMultiplier.x *= -1
				bounced = true
			if position.y < 0:
				directionVectorMultiplier.y *= -1
				bounced = true
			if position.y > bounds.y:
				directionVectorMultiplier.y *= -1
				bounced = true
	return bounced

func checkHasEverBeenInBounds() -> void:
	if hasEverBeenInBounds:
		return
	if not outOfBounds():	# check if ever been on screen, else return early
		hasEverBeenInBounds = true


func checkForEndOfLife():
	if elapsedTime > lifetime and not dying:
		dying = true
		canCauseDamage = false
		startFadeOut()


func updateScale():
	#return
	var size = bulletScaleCurve.get_curve().interpolate(elapsedTime/lifetime)	# elapsedTime already accounts for gameDelta
	scale = originalScale*size
	
