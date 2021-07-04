extends Node2D

var inputVecLastFrame
var inputVec = Vector2()
var velocity
var moveSpeed = 300
var rotationSpeed = 255
var slowMode = false
var slowModeMultiplier = 1
var ROTATION_THRESHOLD = 2 # degs
var selectedLevel = null
var canMove = true

func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	determineInputs()
	applyInputs(delta)
	updateRotation(delta)

func _unhandled_input(_event):
	determineInputs()

func determineInputs():
	inputVecLastFrame = inputVec
	inputVec = Vector2()
	#slowMode = false
	if Input.is_action_pressed("move_right"):
		inputVec.x += 1
	if Input.is_action_pressed("move_left"):
		inputVec.x += -1
	if Input.is_action_pressed("move_up"):
		inputVec.y += -1
	if Input.is_action_pressed("move_down"):
		inputVec.y += 1
#	if Input.is_action_pressed("move_slow"):
#		slowMode = true

	
func applyInputs(delta):
	var moveVec = inputVec	# copy the move vec, and then apply walls and such to it
	if position.x <= 0 and inputVec.x <= -1:
		moveVec.x = 0
	if position.x >= 2000 and inputVec.x >= 1:
		moveVec.x = 0
	if position.y >= 600 and inputVec.y >= 1:
		moveVec.y = 0
	if position.y <= -1400 and inputVec.y <= -1:
		moveVec.y = 0

	if canMove:
		velocity = moveVec * moveSpeed
	else:
		velocity = Vector2()
	if slowMode:
		velocity *= slowModeMultiplier
	position += velocity * delta


func updateRotation(delta):
	if velocity == Vector2():
		return
	var desiredAngle = rad2deg(velocity.angle())
	#print(desiredAngle)
	var diff = desiredAngle - rotation_degrees
	if diff > 360:
		diff -= 360
	if diff < -360:
		diff += 360
	#print(diff)
#	print(cwDiff)
	var dirMultiplier = 1
	if diff > 180 or diff < -180:
		dirMultiplier = -1

	if diff > ROTATION_THRESHOLD:
		rotation_degrees += rotationSpeed*delta*dirMultiplier
	elif diff < -ROTATION_THRESHOLD:
		rotation_degrees -= rotationSpeed*delta*dirMultiplier
	if rotation_degrees > 360:
		rotation_degrees -= 360
	if rotation_degrees < -360:
		rotation_degrees += 360

func save():
	var save_dict = {
		"filename" : get_filename(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
	}
	return save_dict
