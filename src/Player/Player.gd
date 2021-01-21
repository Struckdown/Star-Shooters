extends Node2D


var inputVec = Vector2()	# this represents the Vec2 of button inputs by the player
var inputVecLastFrame = Vector2()
var slowMode = false	# While shift is held, move slower
var slowModeMultiplier = 0.5	# How much slower to move while holding shift
var moveSpeed = 200
var shouldFire = false
var energyLevel = 0.0		# current energy
var energyLimit = 1000.0	# max amount of energy allowed
var energyThreshold = 1	# amount of energy needed to shoot
signal energyUpdated
var touchingBotWall = false	# TODO: Replace this with a bool array of walls touched?
var touchingTopWall = false
var touchingLeftWall = false
var touchingRightWall = false
var lastTouchingLeftWall = false	# false means last touched right wall
var teleporting = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	determineInputs()
	applyInputs(delta)
	updateFakes()
	updateTeleport(delta)


func determineInputs():
	inputVecLastFrame = inputVec
	inputVec = Vector2()
	slowMode = false
	if Input.is_action_pressed("move_right"):
		inputVec.x += 1
	if Input.is_action_pressed("move_left"):
		inputVec.x += -1
	if Input.is_action_pressed("move_up"):
		inputVec.y += -1
	if Input.is_action_pressed("move_down"):
		inputVec.y += 1
	if Input.is_action_pressed("move_slow"):
		slowMode = true
	if Input.is_action_pressed("fire"):
		shouldFire = true
	else:
		shouldFire = false


func applyInputs(delta):
	var moveVec = inputVec	# copy the move vec, and then apply walls and such to it
	if touchingLeftWall and inputVec.x <= -1:
		moveVec.x = 0
		if inputVecLastFrame.x == 0 and not teleporting:
			teleporting = true	# do teleport transition
	if touchingRightWall and inputVec.x >= 1:
		moveVec.x = 0
		if inputVecLastFrame.x == 0 and not teleporting:
			teleporting = true	# teleport!

	if touchingBotWall and inputVec.y >= 1:
		moveVec.y = 0
	if touchingTopWall and inputVec.y <= -1:
		moveVec.y = 0

	var newMoveVec = moveVec * moveSpeed
	if slowMode:
		newMoveVec *= slowModeMultiplier
	position += newMoveVec * delta
	
	if shouldFire and energyLevel >= energyThreshold:
		energyLevel -= energyThreshold
		var b = load("res://Player/PlayerBullet.tscn")
		var bInst = b.instance()
		get_parent().add_child(bInst)
		bInst.position = self.position
		emit_signal("energyUpdated")





func updateFakes():
	$Spaceship/Spaceship_L.frame = $Spaceship.frame
	$Spaceship/Spaceship_R.frame = $Spaceship.frame


func updateTeleport(delta):
	if not teleporting:
		return
	var touchingWall = false
	if touchingLeftWall:
		position.x -= delta*moveSpeed
		touchingWall = true
		lastTouchingLeftWall = true
	if touchingRightWall:
		position.x += delta*moveSpeed
		touchingWall = true
		lastTouchingLeftWall = false
	
	if not touchingWall:
		if lastTouchingLeftWall:
			position = $Spaceship/Spaceship_R.global_position
		else:
			position = $Spaceship/Spaceship_L.global_position
		teleporting = false

# Your energy shield gathers the energy!
func _on_EnergyArea_area_entered(area):
	print("THING HAPPENED")
	if area.is_in_group("Hostile"):
		energyLevel = min(energyLevel+100, energyLimit)
		emit_signal("energyUpdated")


# When the core is hit, you die
func _on_CoreArea_area_entered(area):
	if area.is_in_group("Hostile"):
		print("You got hit in the core! You probably died!")
