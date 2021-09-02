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
var canCauseDamage = true

# Called when the node enters the scene tree for the first time.
func _ready():
	if titleScreenVersion:
		if generatesEnergy:
			setGeneratesEnergy(true)
		$DespawnTimer.autostart = false
		$DespawnTimer.stop()
	if nodeToRotate:
		nodeToRotate = get_node(nodeToRotate)

func init():
	pass	# overridden in children classes

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move(delta*GameManager.gameSpeed)

func _on_DespawnTimer_timeout():
	canCauseDamage = false
	$EndOfLifeTween.interpolate_property(self, "modulate", self.modulate.a, 0, 1)
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
	var sideVec = transform.y
	elapsedTime += delta #(OS.get_ticks_msec() - startTime) * 0.001	# convert to seconds
	horizontalOffset = sin(elapsedTime*waveSpeed+PI/2) * waveStr
	totalHOffset += (horizontalOffset - prevHorizontalOffset)
	sideVec *= totalHOffset

	position += forwardVec * moveSpeed * delta	# forward motion
	position += sideVec * delta	# side wiggle
	prevHorizontalOffset = horizontalOffset
	
	if nodeToRotate:
		nodeToRotate.rotate(deg2rad(rotationSpeed)*delta)

func markEnergyDrained():
	if not energyGenerated:
		energyGenerated = true
		modulate = modulate*0.8


func _on_EndOfLifeTween_tween_completed(_object, _key):
	queue_free()
