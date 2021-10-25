extends Node2D


export(bool) var hasControl = false
export(bool) var godMode = false
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
var energyLimit = 250.0	# max amount of energy allowed
var energyGainMultiplier = 1
var energyThreshold = 1	# amount of energy needed to shoot
signal energyUpdated
onready var energyParticles = load("res://Player/EnergyAbsorptionParticles.tscn")

# Boundary rules
var touchingBotWall = false	# TODO: Replace this with a bool array of walls touched?
var touchingTopWall = false
var touchingLeftWall = false
var touchingRightWall = false
var lastTouchingLeftWall = false	# false means last touched right wall
var teleporting = false

var cheatModeActive = false

signal destroyed
signal gemCollected

# Called when the node enters the scene tree for the first time.
func _ready():
	applyUpgrades()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	determineInputs()
	if hasControl:
		applyInputs(delta)
	updateFakes()
	updateTeleport(delta)

func _unhandled_input(event):
	if event is InputEventKey and event.is_pressed():
		if event.scancode == KEY_G:
			print("Player: Cheat mode not allowed!")
			#cheatModeActive = true
			#print("Cheat mode activated")
	if event.is_action_pressed("fire"):
		shouldFire = true


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
	if not Input.is_action_pressed("fire"):
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
	$EnergyArea/Core.visible = false
	if slowMode:
		velocity *= slowModeMultiplier
		$EnergyArea/Core.visible = true
	position += velocity * delta
	
	if shouldFire and energyLevel >= energyThreshold:
		spawnBullet()


func spawnBullet():
	energyLevel -= energyThreshold
	var b = load("res://Player/PlayerBullet.tscn")
	var bInst = b.instance()
	StatsManager.updateStats("lasersFired", 1)
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
	if not $TeleportSFX.playing:
		$TeleportSFX.play()
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
		StatsManager.updateStats("timesSlipstreamed", 1)

# Your energy shield gathers the energy!
func _on_EnergyArea_area_entered(area):
	if area.is_in_group("generatesEnergy"):
		area.owner.markEnergyDrained()
		spawnEnergyCollectedParticles()
		$EnergyParticleRoot/AbsorbSFX.play()
		var oldEnergyLevel = energyLevel
		energyLevel = min(energyLevel+(25*energyGainMultiplier), energyLimit)
		StatsManager.updateStats("chargeGained", energyLevel-oldEnergyLevel)
		emit_signal("energyUpdated")
	if area.owner.is_in_group("Gem"):
		area.owner.collect()
		emit_signal("gemCollected")
		$GemCollectorSFX.play()

func spawnEnergyCollectedParticles():
		# Spawn particle and attached timer to it, destroy after timer runs out
		var e = energyParticles.instance()
		$EnergyParticleRoot.add_child(e)
		e.emitting = true
		var timer = Timer.new()
		e.add_child(timer)
		timer.connect("timeout", e, "queue_free")
		timer.set_wait_time(e.lifetime)
		timer.start()

# When the core is hit, you die
func _on_CoreArea_area_entered(area):
	if area.is_in_group("Hostile") and not dying and not respawnInvuln and not godMode:
		var bul = area.owner
		if bul.canCauseDamage and not cheatModeActive:
			dying = true
			get_tree().get_nodes_in_group("LevelManager")[0].addCameraShakeIntensity(8)
			StatsManager.updateStats("deaths", 1)
			#hasControl = false
			$AnimationPlayer.play("Explosion")
			var followingP = load("res://Utility/FollowingParticles.tscn")
			followingP = followingP.instance()
			followingP.init(deathExplosion, self)
			get_tree().root.add_child(followingP)

func spawn():
	$AnimationPlayer.play("Spawn")	# Note this messes with the transform
	

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"Explosion":
			emit_signal("destroyed")
			var shockwave = load("res://Player/DeathShockwave.tscn")
			shockwave = shockwave.instance()
			shockwave.global_position = global_position
			get_viewport().add_child(shockwave)
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

func applyUpgrades():
	var upgradeNames = ["energyCap", "startingEnergyCharge", "chargeGain", "magnetRadius"]
	for upgradeName in upgradeNames:
		if upgradeName in UpgradeManager.upgrades:
			var curLevel = UpgradeManager.upgrades[upgradeName]["curLevel"]
			match upgradeName:
				"energyCap":
					energyLimit = UpgradeManager.upgrades["energyCap"]["upgradeLevels"][curLevel] * energyLimit
				"startingEnergyCharge":
					energyLevel = UpgradeManager.upgrades["startingEnergyCharge"]["upgradeLevels"][curLevel] * 0.01 * energyLimit
				"chargeGain":
					energyGainMultiplier = UpgradeManager.upgrades["chargeGain"]["upgradeLevels"][curLevel]
				"magnetRadius":
					$GemMagnetArea/CollisionShape2D.shape.radius = UpgradeManager.upgrades["magnetRadius"]["upgradeLevels"][curLevel]
				_:
					print("No upgrade found for: ", upgradeName)
	emit_signal("energyUpdated")
