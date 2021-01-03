extends Node2D

export(int) var moveSpeed = 200
export(int) var waveStr = 0
onready var startTime = OS.get_ticks_msec()
var elapsedTime
var horizontalOffset = 0
var prevHorizontalOffset = 0
export(int) var waveSpeed = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	waveSpeed *= 10


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move(delta)


func _on_DespawnTimer_timeout():
	queue_free()

func move(delta):
	var forwardVec = Vector2(1, 0).rotated(rotation).normalized()
	var sideVec = transform.y
	elapsedTime = OS.get_ticks_msec() - startTime
	horizontalOffset = sin(elapsedTime/waveSpeed) * waveStr
	sideVec *= (horizontalOffset - 0)
	position += forwardVec * moveSpeed * delta	# forward motion
	position += sideVec * delta	# side wiggle
	prevHorizontalOffset = horizontalOffset
