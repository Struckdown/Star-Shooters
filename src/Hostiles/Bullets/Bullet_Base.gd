extends Node2D

export(int) var moveSpeed = 200
export(int) var waveStr = 0
onready var startTime = OS.get_ticks_msec()
var elapsedTime = 0
var horizontalOffset = 0
var prevHorizontalOffset = 0
export(float) var waveSpeed = 10
export(bool) var generatesEnergy = false
export(bool) var energyGenerated = false
export(String, FILE) var energySprite
var totalHOffset = 0
export(bool) var titleScreenVersion
export(float) var rotationSpeed = 0
export(NodePath) var nodeToRotate
var orbitalChildren = -1	# used by rotationalBullet
var orbitalRotationSpeedDegs = 0
export(bool) var trackYFirst = false	# orthogonal bullets
var canCauseDamage = true
var targetPos = null
var target = null	# used in derived classes

# Called when the node enters the scene tree for the first time.
func _ready():
	if generatesEnergy:
		setGeneratesEnergy(true)
	if titleScreenVersion:
		$DespawnTimer.autostart = false
		$DespawnTimer.stop()
	if nodeToRotate and typeof(nodeToRotate) != TYPE_OBJECT:
		nodeToRotate = get_node(nodeToRotate)

func init():
	pass	# overridden in children classes

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move(delta*GameManager.gameSpeed)
	updateNodeToRotate(delta)

func _on_DespawnTimer_timeout():
	canCauseDamage = false
	startFadeOut()

func startFadeOut():
	var initColor = $Sprite.modulate
	var finalColor = initColor
	finalColor[3] = 0
	$EndOfLifeTween.interpolate_property($Sprite, "modulate", initColor, finalColor, 1)
	$EndOfLifeTween.start()

func setGeneratesEnergy(generates):
	generatesEnergy = generates
	if generatesEnergy:
		changeEnergySprite()

func changeEnergySprite():
	if energySprite:
		get_node("Sprite").texture = load(energySprite)


func move(delta):
	var forwardVec = Vector2(1, 0).rotated(rotation).normalized()
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
	if not energyGenerated:
		energyGenerated = true
		modulate = modulate*0.8


func _on_EndOfLifeTween_tween_completed(_object, _key):
	queue_free()
