extends KinematicBody2D


export(bool) var hasControl = false
export(bool) var godMode = false
var dying = false
var invulnerable = true
var inputVec = Vector2()	# this represents the Vec2 of button inputs by the player
var inputVecLastFrame = Vector2()
var slowMode = false	# While shift is held, move slower
var slowModeMultiplier = 0.5	# How much slower to move while holding shift
export(int) var moveSpeed = 200
var velocity = Vector2()
export(PackedScene) var deathExplosion
var shouldFire = false
var fireHOffset = 5
var fireDelay = 0	# remaining time till next shot
var fireDelayUpperBound# delay between each fired bullet
var fireIndex = 0	# which pos2d to shoot from
var shotDamage = 1	# how much damage each projectile does
#enum playerFireTypes{SPREAD,CHARGE,FOCUSED,REVERSE}
var firePattern
export(bool) var useAlternativeSkin := false

export(float) var energyLevel = 0.0		# current energy
var energyLimit = 250.0	# max amount of energy allowed
var energyGainMultiplier = 1
var energyThreshold = 1	# amount of energy needed to shoot
signal energyUpdated
onready var energyParticles = preload("res://Player/EnergyAbsorptionParticles.tscn")
onready var hitParticles = preload("res://Player/PlayerHitParticles.tscn")
onready var bulletPrefab = preload("res://Player/PlayerBullet.tscn")

# Boundary rules
var touchingBotWall = false	# TODO: Replace this with a bool array of walls touched?
var touchingTopWall = false
var touchingLeftWall = false
var touchingRightWall = false
var lastTouchingLeftWall = false	# false means last touched right wall
var teleporting = false

var cheatModeActive = false

var levelManagerRef
var explosionManagerRef
var scoreBoardRef
export(String) var scoreBoardGroupName = "scoreBoard"

signal destroyed
signal gemCollected

# Called when the node enters the scene tree for the first time.
func _ready():
	if useAlternativeSkin:
		applyAlternativeSkin()
	var levelManagers = get_tree().get_nodes_in_group("LevelManager")
	if len(levelManagers) > 0:
		levelManagerRef = levelManagers[0]
	var explosionManagers = get_tree().get_nodes_in_group("explosionManager")
	if len(explosionManagers) > 0:
		explosionManagerRef = explosionManagers[0]
	var scoreBoardRefs = get_tree().get_nodes_in_group(scoreBoardGroupName)
	if len(scoreBoardRefs) > 0:
		scoreBoardRef = scoreBoardRefs[0]
	var err = GameManager.connect("fireModeUpdated", self, "updateFirePattern")
	if err:
		print("Error:", err)
	updateFirePattern()
	applyUpgrades()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	determineInputs()
	if hasControl:
		applyInputs(delta)
	updateFakes()
	updateTeleport(delta)

func _unhandled_input(event):
	if GameManager.debugMode and event is InputEventKey and event.is_pressed():
		if event.scancode == KEY_G:
			#print("Player: Cheat mode not allowed!")
			cheatModeActive = true
			print("Player: Cheat mode activated")
	if event.is_action_pressed("switchWeapons") and hasControl:
		if len(GameManager.unlockedPlayerFireTypes) > 1:
			$WeaponSwitchSFX.play()
		GameManager.switchToNextFireMode()
	if event.is_action_pressed("fire") and hasControl:
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
	StatsManager.updateStats("overworldDistanceTraveled", velocity.length()*0.00001)
	$EnergyArea/Core.visible = false
	if slowMode:
		velocity *= slowModeMultiplier
		$EnergyArea/Core.visible = true
	
	var _collision = move_and_slide(velocity)
#	position += velocity * delta
	
	if shouldFire and energyLevel >= energyThreshold and fireDelay <= 0:
		performAttack()
	fireDelay = max(0, fireDelay-delta)


func updateFirePattern():
	firePattern = GameManager.playerFireType
	match firePattern:
		GameManager.playerFireTypes.FOCUSED:
			fireDelayUpperBound = 0
			energyThreshold = 1
			shotDamage = 1
		GameManager.playerFireTypes.SPREAD:
			fireDelayUpperBound = 0.1
			energyThreshold = 4
			shotDamage = 1
		GameManager.playerFireTypes.CHARGE:
			fireDelayUpperBound = 0.5
			energyThreshold = 30
			shotDamage = 30
		GameManager.playerFireTypes.REVERSE:
			fireDelayUpperBound = 0
			energyThreshold = 3
			shotDamage = 1
		_:
			print("No fire type matched!")
			return

func performAttack():
	energyLevel -= energyThreshold
	$FiringSFX.play()
	fireDelay = fireDelayUpperBound
	emit_signal("energyUpdated")
	match firePattern:
		GameManager.playerFireTypes.FOCUSED:
			spawnBullet(get_node("FireGroups/2Straight"), fireIndex)
			fireIndex = (fireIndex+1)%2
		GameManager.playerFireTypes.SPREAD:
			for i in range(4):
				spawnBullet(get_node("FireGroups/4Arc"), i)
		GameManager.playerFireTypes.CHARGE:
			spawnBullet(get_node("FireGroups/strongSlow"), 0)
		GameManager.playerFireTypes.REVERSE:
			for i in range(3):
				spawnBullet(get_node("FireGroups/forwardBackward"), i)
		_:
			print("No attack pattern matched?")

func spawnDemoBullet():
	spawnBullet(get_node("FireGroups/2Straight"), fireIndex)
	fireIndex = (fireIndex+1)%2

func spawnBullet(pos2Dgroup:Node2D, shotIndex):
	var bInst = bulletPrefab.instance()
	StatsManager.updateStats("lasersFired", 1)
	get_viewport().add_child(bInst)
	#get_parent().move_child(bInst, 2)	# Force bullet to be under space
	bInst.position = self.position
	var pos2D = pos2Dgroup.get_child(shotIndex)
	bInst.position += pos2D.position
	bInst.rotation_degrees += pos2D.rotation_degrees - 90
	bInst.scale = pos2D.scale
	bInst.damage = shotDamage
	bInst.explosionManagerRef = explosionManagerRef


func updateFakes():
	$SpritesRoot/Spaceship_L.frame = $SpritesRoot/Spaceship.frame
	$SpritesRoot/Spaceship_R.frame = $SpritesRoot/Spaceship.frame

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
		var energyAmountToGenerate = area.owner.energyAmountToGenerate
		if area.owner.has_method("markEnergyDrained"):
			area.owner.markEnergyDrained()
#		GameManager.score += 5	# shot grazing is worth 5 points each # Edit: Removed due to artificially inflating scores. >.>
		if scoreBoardRef:
			scoreBoardRef.updateScore()
		spawnEnergyCollectedParticles()
		$EnergyParticleRoot/AbsorbSFX.play()
		var oldEnergyLevel = energyLevel
		energyLevel = min(energyLevel+(energyAmountToGenerate*energyGainMultiplier), energyLimit)
		StatsManager.updateStats("chargeGained", energyLevel-oldEnergyLevel)
		emit_signal("energyUpdated")
	if area.owner.is_in_group("Gem"):
		area.owner.collect()
		emit_signal("gemCollected")
		$GemCollectorSFX.pitch_scale = rand_range(0.75, 1.75)
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
	if area.is_in_group("Hostile") and not dying and not invulnerable and not godMode:
		var bul = area.owner
		if bul.canCauseDamage and not cheatModeActive:
			var HP = hitParticles.instance()
			HP.global_rotation = bul.global_rotation
			$EnergyParticleRoot.add_child(HP)
			if levelManagerRef:
				levelManagerRef.addCameraShakeIntensity(2)
			takeDamage()

func takeDamage():
	energyLevel -= energyLimit*0.25
	emit_signal("energyUpdated")
	if energyLevel <= 0 or GameManager.instaKillMode:
		dying = true
		if levelManagerRef:
			levelManagerRef.addCameraShakeIntensity(8)
		StatsManager.updateStats("deaths", 1)
		#hasControl = false
		$AnimationPlayer.play("Explosion")
		var followingP = load("res://Utility/FollowingParticles.tscn")
		followingP = followingP.instance()
		followingP.init(deathExplosion, self)
		followingP.startEmitting()
		get_tree().root.add_child(followingP)
	else:
		$InvulnAnimPlayer.play("HitInvuln")
		invulnerable = true

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
			if not useAlternativeSkin:
				$AnimationPlayer.play("Flying")
			hasControl = true
	


func _on_InvulnAnimPlayer_animation_finished(_anim_name):
	invulnerable = false


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

func applyAlternativeSkin():
	useAlternativeSkin = true
	for child in $SpritesRoot.get_children():
		child.texture = load("res://Space Shooter Redux/PNG/Enemies/enemyRed1.png")
		$SpritesRoot/Spaceship.rotation = deg2rad(180)
		child.hframes = 1
