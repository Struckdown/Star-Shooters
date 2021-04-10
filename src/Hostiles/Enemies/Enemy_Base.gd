extends Node2D

export(int) var pointsWorth = 100
export(float) var speed = 140
var velocity
export(int) var maxHealth = 25
onready var health = maxHealth
signal destroyed
export(PackedScene) var explosionType
var explosionParticles
export(Vector2) var moveGoal	# vector coordinate where enemy is trying to get to
#export(NodePath) var moveGoalObject	# if given, try to move towards this object's position	#TODO. This is not implemented
var levelBounds
var levelViewport
var target	# thing to shoot
export(String, "straight", "hoverRandomPoint", "hoverMoveGoal", "TBD") var flyingPattern
var healthBarRef

# Called when the node enters the scene tree for the first time.
func _ready():
	levelBounds = get_tree().get_nodes_in_group("LevelBoundary")
	if len(levelBounds) > 0:
		levelBounds = levelBounds[0]
		levelViewport = levelBounds.get_parent()
	target = get_tree().get_nodes_in_group("Player")
	if len(target) > 0:
		target = target[0]
	if moveGoal:
		moveGoal += position
	if not moveGoal and levelBounds:
		getNewMoveGoal()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move(delta)
	aimAtTarget()


#Called when the enemy is destroyed
func _exit_tree():
	emit_signal("destroyed", pointsWorth)


func move(d):
	match flyingPattern:
		"straight":
			position += Vector2(d*speed, 0).rotated(rotation)
		"hoverRandomPoint", "hoverMoveGoal":
			if moveGoal:
				velocity = position.direction_to(moveGoal) * speed * d
				if position.distance_squared_to(moveGoal) > 5*5:
					position += velocity

func aimAtTarget():
	match flyingPattern:
		"hoverRandomPoint":
			if target:
				look_at(target.position)
			else:
				if len(get_tree().get_nodes_in_group("Player")) > 0:
					target = get_tree().get_nodes_in_group("Player")[0]

func destroy():
	explosionParticles = load("res://Utility/FollowingParticles.tscn").instance()
	explosionParticles.init(explosionType, self)
	get_tree().root.add_child(explosionParticles)
	$AnimationPlayer.play("Death")
	$ExplosionTimer.start()


func _on_ExplosionTimer_timeout():
#	remove_child(explosionParticles)
#	get_parent().add_child(explosionParticles)
	queue_free()


func _on_Area2D_area_entered(area):
	if area.is_in_group("PlayerBullet"):
		if health > 0:
			health -= 1
			if healthBarRef:
				healthBarRef.applyDamage(float(health)/float(maxHealth)*100)
			area.owner.destroy()
			if health <= 0:
				destroy()

func getNewMoveGoal():
	#var mapCenter = levelBounds.position
	var mapSize = levelViewport.get_viewport().size
	randomize()
	var xRand = rand_range(mapSize.x * 0.1, mapSize.x * 0.9)
	var yRand = rand_range(mapSize.y * 0.1, mapSize.y * 0.4) + 200	# 200 is from wave offset spawning things off-camera
	moveGoal = Vector2(xRand, yRand)