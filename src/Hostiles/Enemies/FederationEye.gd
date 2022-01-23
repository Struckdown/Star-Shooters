extends "res://Hostiles/Enemies/Enemy_Base.gd"

var shieldIsActive = true setget setShield
var shieldDownTime = 2
var shieldUpTime = 3

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _ready():
	._ready()
	$ShieldRoot/ShieldTimer.start(shieldUpTime)

func setShield(active:bool):
	shieldIsActive = active
	if active:
		$ShieldRoot/ShieldAnimationPlayer.play("activate")
	else:
		$ShieldRoot/ShieldAnimationPlayer.play_backwards("activate")


func _on_ShieldTimer_timeout():
	if shieldIsActive:
		$ShieldRoot/ShieldTimer.start(shieldDownTime)
	else:
		$ShieldRoot/ShieldTimer.start(shieldUpTime)
	setShield(!shieldIsActive)
