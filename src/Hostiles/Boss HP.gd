extends Control

var maxSize = 600
var fillPercentage = 100
var bufferFillPercentage = 100
var bufferTargetFillPercentage = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().healthBarRef = self
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	if Input.is_action_pressed("fire"):
#		applyDamage(0.1)
	if (bufferFillPercentage > bufferTargetFillPercentage):
		updateBufferVisuals()


# Public function
func applyDamage(percentFilled):
	updateVisuals(percentFilled)
	$CanvasLayer/DamageUpdateTimer.start()

# Percent filled is a number between 0 and 100
func updateVisuals(percentFilled):
	fillPercentage = percentFilled
	var fillPixels = float(percentFilled) * maxSize * 0.01
	$CanvasLayer/HpBar.rect_size.x = fillPixels

func updateBufferVisuals():
	bufferFillPercentage -= 0.1
	if bufferFillPercentage <= bufferTargetFillPercentage:
		bufferFillPercentage = bufferTargetFillPercentage
	var fillPixels = float(bufferFillPercentage) * maxSize * 0.01
	$CanvasLayer/HpBarDamagedBuffer.rect_size.x = fillPixels

func _on_DamageUpdateTimer_timeout():
	bufferTargetFillPercentage = fillPercentage
