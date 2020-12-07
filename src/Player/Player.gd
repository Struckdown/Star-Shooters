extends Node2D


var moveVec = Vector2()
var slowMode = false	# While shift is held, move slower
var slowModeMultiplier = 0.5	# How much slower to move while holding shift
var moveSpeed = 200
var shouldFire = false
var energyLevel = 0		# current energy
var energyThreshold = 1	# amount of energy needed to shoot

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	determineInputs()
	applyInputs(delta)


func determineInputs():
	moveVec = Vector2()
	slowMode = false
	if Input.is_action_pressed("move_right"):
		moveVec.x += 1
	if Input.is_action_pressed("move_left"):
		moveVec.x += -1
	if Input.is_action_pressed("move_up"):
		moveVec.y += -1
	if Input.is_action_pressed("move_down"):
		moveVec.y += 1
	if Input.is_action_pressed("move_slow"):
		slowMode = true
	if Input.is_action_pressed("fire"):
		shouldFire = true
	else:
		shouldFire = false


func applyInputs(delta):
	var newMoveVec = moveVec * moveSpeed
	if slowMode:
		newMoveVec *= slowModeMultiplier
	position += newMoveVec * delta
	
	if shouldFire and energyLevel >= energyThreshold:
		energyLevel -= energyThreshold
		$CanvasLayer/EnergyLabel.text = "Energy:" + str(energyLevel)
		var b = load("res://Player/PlayerBullet.tscn")
		var bInst = b.instance()
		get_parent().add_child(bInst)
		bInst.position = self.position
	

# Your energy shield gathers the energy!
func _on_EnergyArea_body_entered(body):
	if body.is_in_group("Hostile"):
		energyLevel += 100
		$CanvasLayer/EnergyLabel.text = "Energy:" + str(energyLevel)


# When the core is hit, you die
func _on_CoreArea_body_entered(body):
	if body.is_in_group("Hostile"):
		print("You got hit in the core! You probably died!")
