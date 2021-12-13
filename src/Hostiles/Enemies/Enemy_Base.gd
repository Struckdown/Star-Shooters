extends Node2D

export(int) var pointsWorth = 100
export(float) var speed = 110
export(float) var maxRotationSpeed = PI / 64
export(float) var maxSpeed = 1.5
export(bool) var useAcclerationInsteadOfLinearVelocity = false
var velocity := Vector2.ZERO
var acceleration := Vector2.ZERO
export(float) var leashRadius = 10
export(float) var slowingDistance := 50.0
export(int) var maxHealth := 25
onready var health = maxHealth
export(float) var deathShakeIntensity = 3
export(int) var gemValue = 10
export(PackedScene) var explosionType
var followingParticles = preload("res://Utility/FollowingParticles.tscn")
var explosionParticles
export(Vector2) var moveGoal	# vector coordinate where enemy is trying to get to
var originalMoveGoal
export(Array, NodePath) var flyPaths
#export(Array, float) var delayBetweenNextFlightPath #Not yet implemented
var flyPathIndex = 0
export(bool) var loopFlyPaths
var flyPoints
var flyIndex = 0
#export(NodePath) var moveGoalObject	# if given, try to move towards this object's position	#TODO. This is not implemented
var levelBounds
export(NodePath) var target	# thing to shoot
export(String, "straight", "hoverRandomPoint", "hoverMoveGoal", "followPath", "homingNoStop", "TBD") var flyingPattern
export(Vector2) var turningRateDegsBounds
var turningRateDeg
var healthBarRef
export(bool) var isBoss = false
export(bool) var deathCountsAsWaveProgression = true
var loadedGem = preload("res://Hostiles/GemSpawner.tscn")
var timeSinceLastGoal := 0.0
var levelManagerRef
var explosionManagerRef

signal destroyed
signal tookDamage
signal wantsNewTarget

# Called when the node enters the scene tree for the first time.
func _ready():
	levelManagerRef = find_parent("Level")
	var explosionManagers = get_tree().get_nodes_in_group("explosionManager")
	if len(explosionManagers) > 0:
		explosionManagerRef = explosionManagers[0]
	if len(flyPaths) > 0:
		flyPoints = get_node(flyPaths[flyPathIndex]).curve.get_baked_points()
		
	target = get_tree().get_nodes_in_group("Player")
	if len(target) > 0:
		target = target[0]
	if flyingPattern == "hoverMoveGoal":
		moveGoal += position
		originalMoveGoal = moveGoal
	if not moveGoal:
		getNewMoveGoal()
		originalMoveGoal = moveGoal
	turningRateDeg = rand_range(turningRateDegsBounds[0], turningRateDegsBounds[1])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move(delta)
	aimAtTarget()


#Called when the enemy is destroyed
func _exit_tree():
	if health <= 0:
		spawnGems()
	if deathCountsAsWaveProgression:
		emit_signal("destroyed", pointsWorth)
	get_tree().call_group("EnemyDestroyedListener", "OnEnemyDestroyed", self)


func move(d):
	var deltaSpeed = speed*d*GameManager.gameSpeed
	timeSinceLastGoal += d
	acceleration = Vector2.ZERO
	var distToEndPoint = position.distance_squared_to(moveGoal)
	match flyingPattern:
		"straight":
			acceleration = Vector2(deltaSpeed, 0).rotated(rotation)
		"hoverRandomPoint", "hoverMoveGoal":
			if moveGoal:
				if (distToEndPoint <= slowingDistance or timeSinceLastGoal > 1) and useAcclerationInsteadOfLinearVelocity:
					timeSinceLastGoal = 0
					var r = leashRadius * sqrt(randf())
					var theta = randf() * 2 * PI
					var circlePoint = Vector2(originalMoveGoal.x+r*cos(theta), originalMoveGoal.y+r*sin(theta))
					moveGoal = circlePoint
				if distToEndPoint > slowingDistance:
					acceleration = position.direction_to(moveGoal) * deltaSpeed
		"followPath":
			if len(flyPaths) <= 0:
				return
			var flyTarget = flyPoints[flyIndex]
			if position.distance_to(flyTarget) < (deltaSpeed*4):	#fly point reached
				flyIndex = wrapi(flyIndex + 1, 0, flyPoints.size())
				flyTarget = flyPoints[flyIndex]
				if flyIndex == 0:	# we reached the end of the current fly path
					flyPathIndex += 1
					if flyPathIndex < len(flyPaths):
						flyPoints = get_node(flyPaths[flyPathIndex]).curve.get_baked_points()
					else:
						if loopFlyPaths:
							flyPathIndex = 0
							flyPoints = get_node(flyPaths[flyPathIndex]).curve.get_baked_points()
						else:
							queue_free()
			acceleration = position.direction_to(flyTarget) * deltaSpeed
			var desiredAngle = get_angle_to(global_position+acceleration)
			desiredAngle = sign(desiredAngle) * min(abs(desiredAngle), maxRotationSpeed)
			rotation += desiredAngle
		"homingNoStop":
			var deltaAngle
			var distToTarget = -1
			if is_instance_valid(target):
				distToTarget = global_position.distance_squared_to(target.global_position)
				deltaAngle = get_angle_to(target.global_position)
			else:
				deltaAngle = 0
				target = get_tree().get_nodes_in_group("Player")	# default target
				if len(target) > 0:
					target = target[0]
				emit_signal("wantsNewTarget")
			if distToTarget > 0 and distToTarget <= 4000:
				emit_signal("wantsNewTarget")
			acceleration = Vector2(deltaSpeed, 0).rotated(rotation) * deltaSpeed
			rotation += min(abs(deltaAngle), deg2rad(turningRateDeg)) * sign(deltaAngle)

	if useAcclerationInsteadOfLinearVelocity:
		if distToEndPoint > slowingDistance:
			velocity += acceleration.normalized() * deltaSpeed
		else:
			velocity *= distToEndPoint / slowingDistance
		if velocity.length() > maxSpeed:
			velocity = velocity/velocity.length() * maxSpeed
	else:
		velocity = acceleration.normalized() * abs(deltaSpeed)
	position += velocity

func aimAtTarget():
	match flyingPattern:
		"hoverRandomPoint":
			if is_instance_valid(target):
				var deltaAngle = get_angle_to(target.global_position)
				rotation += min(abs(deltaAngle), deg2rad(maxRotationSpeed)) * sign(deltaAngle)
			else:
				if len(get_tree().get_nodes_in_group("Player")) > 0:
					target = get_tree().get_nodes_in_group("Player")[0]

func destroy():
	if explosionManagerRef:
		explosionManagerRef.requestExplosion("multi", position, self)
	$AnimationPlayer.play("Death")
	$ExplosionTimer.start()
	for child in get_children():
		if child.has_method("markOwnerAsDestroyed"):
			child.markOwnerAsDestroyed()

func scaleOut():
	$DeathScaleTween.interpolate_property(self, "scale", self.scale, scale*Vector2(0.2, 0.2), 0.3)
	$DeathScaleTween.start()

func _on_ExplosionTimer_timeout():
	if levelManagerRef:
		levelManagerRef.addCameraShakeIntensity(deathShakeIntensity)
	var partsParticles = load("res://Explosions/PartsEmitter.tscn").instance()
	get_viewport().add_child(partsParticles)
	partsParticles.global_position = global_position
	partsParticles.emitting = true
	queue_free()

func setHealthBarRef(ref):
	healthBarRef = ref

func _on_Area2D_area_entered(area):	# this code block might be redundant with the player bullet having the same code
	if area.is_in_group("PlayerBullet"):
		if health > 0:
			takeDamage(area.owner.damage)
			area.owner.destroy()

func applyDamage(damage):
	if health > 0:
		takeDamage(damage)

func takeDamage(damage):
	health = max(health - damage, 0)	# disallow going below 0
	if not $HitSFX.playing:
		$HitSFX.play()
	emit_signal("tookDamage", float(health)/float(maxHealth))	# used by weapon manager
	updateScratches()
	if healthBarRef:
		healthBarRef.applyDamage(min(health, damage))
	if health <= 0:
		StatsManager.updateStats("enemiesKilled", 1)
		if isBoss:
			StatsManager.updateStats("bossesDefeated", 1)
		destroy()

func updateScratches():
	var healthFrac = float(health)/float(maxHealth)
	if healthFrac < 0.75:
		$Sprite/Scratch1.show()
	if healthFrac < 0.50:
		$Sprite/Scratch2.show()
	if healthFrac < 0.25:
		$Sprite/Scratch3.show()


func getNewMoveGoal():
	#var mapCenter = levelBounds.position
	var mapSize = get_viewport().size
	randomize()
	var xRand = rand_range(mapSize.x * 0.2, mapSize.x * 0.7)	# avoid parking on the right side
	var yRand = rand_range(mapSize.y * 0.1, mapSize.y * 0.4) #+ 200	# 200 is from wave offset spawning things off-camera
	moveGoal = Vector2(xRand, yRand)

func spawnGems():
	var g = loadedGem.instance()
	g.gemsRemaining = gemValue
	g.global_position = global_position
	get_viewport().call_deferred("add_child", g)

func setActive(nowActive:bool) -> void:
	if nowActive:
		$Sprite.modulate.darkened(0)
	else:
		$Sprite.modulate.darkened(0.5)
	$Area2D/CollisionShape2D.disabled = !nowActive
	$WeaponManager.active = nowActive
	$WeaponManager.updatePhase()
	$WeaponManager.processing = nowActive
