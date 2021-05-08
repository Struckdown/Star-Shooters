extends Node2D


export(bool) var hasControl = false
var dying = false
var respawnInvuln = true
var inputVec = Vector2()	# this represents the Vec2 of button inputs by the player
var inputVecLastFrame = Vector2()
var slowMode = false	# While shift is held, move slower
var slowModeMultiplier = 0.5	# How much slower to move while holding shift
export(int) var moveSpeed = 200
var velocity = Vector2()
export(PackedScene) var deathExplosion
var shouldFire = false
var fireHOffset = 5

var energyLevel = 0.0		# current energy
var energyLimit = 1000.0	# max amount of energy allowed
var energyThreshold = 1	# amount of energy needed to shoot
signal energyUpdated

# Boundary rules
var touchingBotWall = false	# TODO: Replace this with a bool array of walls touched?
var touchingTopWall = false
var touchingLeftWall = false
var touchingRightWall = false
var lastTouchingLeftWall = false	# false means last touched right wall
var teleporting = false

signal destroyed
signal gemCollected

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	determineInputs()
	if hasControl:
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

	velocity = moveVec * moveSpeed
	if slowMode:
		velocity *= slowModeMultiplier
	position += velocity * delta
	
	if shouldFire and energyLevel >= energyThreshold:
		spawnBullet()


func spawnBullet():
	energyLevel -= energyThreshold
	var b = load("res://Player/PlayerBullet.tscn")
	var bInst = b.instance()
	get_parent().add_child(bInst)
	get_parent().move_child(bInst, 2)	# Force bullet to be under space
	bInst.position = self.position
	fireHOffset *= -1
	var offset = Vector2(fireHOffset, -10)
	bInst.position += offset
	emit_signal("energyUpdated")


func updateFakes():
	$SpritesRoot/Spaceship_L.frame = $SpritesRoot/Spaceship.frame
	$SpritesRoot/Spaceship_R.frame = $SpritesRoot/Spaceship.frame
	#$SpritesRoot/Spaceship_L.position.x = $SpritesRoot/Spaceship.position.x - 420
	#$SpritesRoot/Spaceship_R.position.x = $SpritesRoot/Spaceship.position.x + 420
	

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
			position = $SpritesRoot/Spaceship_R.global_position
		else:
			position = $SpritesRoot/Spaceship_L.global_position
		teleporting = false

# Your energy shield gathers the energy!
func _on_EnergyArea_area_entered(area):
	if area.is_in_group("Hostile"):
		if area.owner.generatesEnergy:
			energyLevel = min(energyLevel+100, energyLimit)
			emit_signal("energyUpdated")
	if area.owner.is_in_group("Gem"):
		area.owner.queue_free()
		emit_signal("gemCollected")


# When the core is hit, you die
func _on_CoreArea_area_entered(area):
	if area.is_in_group("Hostile") and not dying and not respawnInvuln:
		dying = true
		#hasControl = false
		$AnimationPlayer.play("Explosion")
		var followingP = load("res://Utility/FollowingParticles.tscn")
		followingP = followingP.instance()
		followingP.init(deathExplosion, self)
		get_tree().root.add_child(followingP)

func spawn():
	$AnimationPlayer.play("Spawn")
	

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"Explosion":
			emit_signal("destroyed")
			queue_free()
		"Spawn":
			$AnimationPlayer.play("Flying")
			hasControl = true
	


func _on_InvulnAnimPlayer_animation_finished(_anim_name):
	respawnInvuln = false


func _on_GemMagnetArea_area_entered(area):
	if area.is_in_group("Gem"):
		area.owner.playerRef = self


func _on_GemMagnetArea_area_exited(area):
	if area.is_in_group("Gem"):
		if area.owner:	# check if gem still exists
			area.owner.playerRef = null

func checkIfGemInMagnet(gem):
	return $GemMagnetArea.global_position.distance_to(gem.global_position) <= $GemMagnetArea/CollisionShape2D.shape.radius
