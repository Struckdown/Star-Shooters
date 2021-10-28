extends Node2D

var asteroid = preload("res://Hostiles/Enemies/Asteroid.tscn")
var largeAsteroid = preload("res://Hostiles/Enemies/LargeAsteroid.tscn")
var aggressionMultiplier = 1.0
var asteroidSpawnValue = 0
var spawnTime = 1.0
var totalDelta = 0.0
var targetPosition = Vector2.ZERO
var loadedGem = preload("res://Hostiles/Gem.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	$Tween.interpolate_method(self, "increaseAggression", 1, 2, 120, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	totalDelta += delta

func increaseAggression(_aggresionLevel):
	aggressionMultiplier = _aggresionLevel * GameManager.gameSpeed

func _on_SpeedAsteroidTimer_timeout():
	var a = asteroid.instance()
	add_child(a)
	var viewport = get_viewport_rect().size
	a.position.x = rand_range(0, viewport.x)
	a.position.y = rand_range(-15, -80)
	a.rotation_degrees = rand_range(75, 125)
	a.speed = rand_range(150, 180) * aggressionMultiplier
	a.init()
	$SpeedAsteroidTimer.start(spawnTime/aggressionMultiplier)

func _on_LargeGroupAsteroidTimer_timeout():
	var viewport = get_viewport_rect().size
	for _i in range(int(15*aggressionMultiplier)):
		var a = asteroid.instance()
		add_child(a)
		a.position.x = rand_range(0, viewport.x) * 1.3 - viewport.x*0.15
		a.position.y = rand_range(-15, -120)
		a.rotation_degrees = rand_range(75, 125)
		a.speed = rand_range(100, 150) * aggressionMultiplier
		a.init()
		$LargeGroupAsteroidTimer.start(10/aggressionMultiplier)


func _on_LargeAsteroid_timeout():
	var a = largeAsteroid.instance()
	add_child(a)
	var viewport = get_viewport_rect().size
	a.position.x = rand_range(0, viewport.x) * 1.3 - viewport.x*0.15
	a.position.y = rand_range(-35, -70)
	a.rotation_degrees = rand_range(75, 125)
	a.speed = rand_range(50, 70) * aggressionMultiplier
	a.init()
	$LargeAsteroidTimer.start(3/aggressionMultiplier)


func _on_TargetingAsteroidsTimer_timeout():
	getPlayerPosition()
	var viewport = get_viewport_rect().size
	for _i in range(3):
		var a = asteroid.instance()
		add_child(a)
		a.global_position.x = rand_range(0, viewport.x) * 1.3 - viewport.x*0.15
		a.global_position.y = rand_range(-15, -130)
		a.rotation_degrees = rand_range(75, 125)
		a.rotation = a.global_position.angle_to_point(targetPosition) + deg2rad(180)
		a.speed = rand_range(250, 280) * aggressionMultiplier
		a.init()
	$TargetingAsteroidsTimer.start(2/aggressionMultiplier)

func getPlayerPosition():
	var players = get_tree().get_nodes_in_group("Player")
	var player
	if len(players) > 0:
		player = players[0]
		targetPosition = player.global_position


func _on_GemTimer_timeout():
	spawnGems()
	$GemTimer.start(4/aggressionMultiplier)


func spawnGems():
	var viewportSize = get_viewport_rect().size
	var viewport = get_viewport()
	for _i in range(15*aggressionMultiplier):
		var g = loadedGem.instance()
		viewport.add_child(g)
		g.global_position.x = rand_range(0, viewportSize.x) * 1.3 - viewportSize.x*0.15
		g.global_position.y = rand_range(-15, -430)
		g.dragCoefficient = 0
		g.velocity = Vector2(1, 0).rotated(deg2rad(rand_range(75,105))) * rand_range(100,250) * aggressionMultiplier
