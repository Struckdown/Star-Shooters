extends Node2D

export(int) var pointsWorth = 100
export(float) var speed = 140
var velocity
export(int) var maxHealth = 25
onready var health = maxHealth
export(float) var deathShakeIntensity = 3
export(int) var gemValue = 10
export(PackedScene) var explosionType
var followingParticles = preload("res://Utility/FollowingParticles.tscn")
var explosionParticles
export(Vector2) var moveGoal	# vector coordinate where enemy is trying to get to
export(Array, NodePath) var flyPaths
#export(Array, float) var delayBetweenNextFlightPath #Not yet implemented
var flyPathIndex = 0
export(bool) var loopFlyPaths
var flyPoints
var flyIndex = 0
#export(NodePath) var moveGoalObject	# if given, try to move towards this object's position	#TODO. This is not implemented
var levelBounds
var levelViewport
var target	# thing to shoot
export(String, "straight", "hoverRandomPoint", "hoverMoveGoal", "followPath", "TBD") var flyingPattern
var healthBarRef
export(bool) var isBoss = false
var loadedGem = preload("res://Hostiles/GemSpawner.tscn")

var levelManagerRef

signal destroyed
signal tookDamage


# Called when the node enters the scene tree for the first time.
func _ready():
	levelManagerRef = find_parent("Level")
	if len(flyPaths) > 0:
		flyPoints = get_node(flyPaths[flyPathIndex]).curve.get_baked_points()
		
		
	levelBounds = get_tree().get_nodes_in_group("LevelBoundary")
	if len(levelBounds) > 0:
		levelBounds = levelBounds[0]
		levelViewport = levelBounds.get_parent()
	target = get_tree().get_nodes_in_group("Player")
	if len(target) > 0:
		target = target[0]
	if flyingPattern == "hoverMoveGoal":
		moveGoal += position
		#moveGoal.y += 200
	if not moveGoal and levelBounds:
		getNewMoveGoal()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move(delta)
	aimAtTarget()


#Called when the enemy is destroyed
func _exit_tree():
	if health <= 0:
		spawnGems()
	emit_signal("destroyed", pointsWorth)
	get_tree().call_group("EnemyDestroyedListener", "OnEnemyDestroyed", self)


func move(d):
	var deltaSpeed = speed*d*GameManager.gameSpeed
	match flyingPattern:
		"straight":
			position += Vector2(deltaSpeed, 0).rotated(rotation)
		"hoverRandomPoint", "hoverMoveGoal":
			if moveGoal:
				velocity = position.direction_to(moveGoal) * deltaSpeed
				if position.distance_squared_to(moveGoal) > 5*5:
					position += velocity
		"followPath":
			if len(flyPaths) <= 0:
				return
			var flyTarget = flyPoints[flyIndex]
			if position.distance_to(flyTarget) < (deltaSpeed):	#fly point reached
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
					
			velocity = position.direction_to(flyTarget) * deltaSpeed
			look_at(global_position+velocity)
			position += velocity

func aimAtTarget():
	match flyingPattern:
		"hoverRandomPoint":
			if is_instance_valid(target):
				look_at(target.position)
			else:
				if len(get_tree().get_nodes_in_group("Player")) > 0:
					target = get_tree().get_nodes_in_group("Player")[0]

func destroy():
	explosionParticles = followingParticles.instance()
	explosionParticles.init(explosionType, self)
	get_viewport().add_child(explosionParticles)
	$AnimationPlayer.play("Death")
	$ExplosionTimer.start()
	for child in get_children():
		if child.has_method("markOwnerAsDestroyed"):
			child.markOwnerAsDestroyed()

func scaleOut():
	$DeathScaleTween.interpolate_property(self, "scale", self.scale, Vector2(0.2, 0.2), 0.3)
	$DeathScaleTween.start()

func _on_ExplosionTimer_timeout():
	levelManagerRef.addCameraShakeIntensity(deathShakeIntensity)
	var partsParticles = load("res://Explosions/PartsEmitter.tscn").instance()
	get_viewport().add_child(partsParticles)
	partsParticles.global_position = global_position
	partsParticles.emitting = true
	queue_free()

func setHealthBarRef(ref):
	healthBarRef = ref

func _on_Area2D_area_entered(area):
	if area.is_in_group("PlayerBullet"):
		if health > 0:
			takeDamage()
			area.owner.destroy()

func applyDamage():
	if health > 0:
		takeDamage()

func takeDamage():
	health = max(health - 1, 0)	# disallow going below 0
	if not $HitSFX.playing:
		$HitSFX.play()
	emit_signal("tookDamage", float(health)/float(maxHealth))	# used by weapon manager
	updateScratches()
	if healthBarRef:	# technically this won't work correctly if there is overkill
		healthBarRef.applyDamage(1)
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
	var mapSize = levelViewport.get_viewport().size
	randomize()
	var xRand = rand_range(mapSize.x * 0.1, mapSize.x * 0.9)
	var yRand = rand_range(mapSize.y * 0.1, mapSize.y * 0.4) #+ 200	# 200 is from wave offset spawning things off-camera
	moveGoal = Vector2(xRand, yRand)

func spawnGems():
	var g = loadedGem.instance()
	g.gemsRemaining = gemValue
	g.global_position = global_position
	get_viewport().call_deferred("add_child", g)
