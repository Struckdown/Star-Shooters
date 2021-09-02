extends Control

export(float, 1) var fill setget fill_set

var maxSize = 600
var fillPercentage = 100
var bufferFillPercentage = 100
var bufferTargetFillPercentage = 100

var cur_hp = 100
var hpTotal = 100


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	#if (bufferFillPercentage > bufferTargetFillPercentage):
		#updateBufferVisuals()


func setup(_hpTotal, bossName):
	$"VBoxContainer/Boss_Name_Table/Boss Name".text = bossName
	hpTotal = _hpTotal
	cur_hp = _hpTotal
	fill = hpTotal/cur_hp
	updateBars()
	$AnimationPlayer.play("appear")

func updateBars():
	var amountRemaining = fill
	for bar in $VBoxContainer/BG/HPBars.get_children():
		var childCount = 3
		var barFill = clamp(amountRemaining * childCount, 0, 1)
		updateVisuals(bar, barFill*100)
		amountRemaining -= (1.0/float(childCount))


# Public function
func applyDamage(damage):
	cur_hp -= damage
	fill = float(cur_hp)/float(hpTotal)
	updateBars()
	#$DamageUpdateTimer.start()

func fill_set(_value):
	fill = clamp(_value, 0, 1)

# Percent filled is a number between 0 and 100
func updateVisuals(bar, percentFilled):
	bar.value = percentFilled

func updateBufferVisuals():
	bufferFillPercentage -= 0.3
	if bufferFillPercentage <= bufferTargetFillPercentage:
		bufferFillPercentage = bufferTargetFillPercentage
#	var fillPixels = float(bufferFillPercentage) * maxSize * 0.01
	#$HpBarDamagedBuffer.rect_size.x = fillPixels

func _on_DamageUpdateTimer_timeout():
	bufferTargetFillPercentage = fillPercentage
