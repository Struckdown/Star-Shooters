extends Node2D

var asteroid = preload("res://Hostiles/Enemies/Asteroid.tscn")
var largeAsteroid = preload("res://Hostiles/Enemies/LargeAsteroid.tscn")
var aggressionMultiplier = 1.0
var asteroidSpawnValue = 0
var spawnTime = 1.0
var totalDelta = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	$Tween.interpolate_method(self, "increaseAggression", 1, 2, 120, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	totalDelta += delta

func increaseAggression(_aggresionLevel):
	aggressionMultiplier = _aggresionLevel

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
	for _i in range(int(15*aggressionMultiplier)):
		var a = asteroid.instance()
		add_child(a)
		var viewport = get_viewport_rect().size
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
	$LargeAsteroidTimer.start(spawnTime/aggressionMultiplier)


func _on_TargetingAsteroidsTimer_timeout():
	var player = get_tree().get_nodes_in_group("Player")[0]
	for _i in range(3):
		var a = asteroid.instance()
		add_child(a)
		var viewport = get_viewport_rect().size
		a.global_position.x = rand_range(0, viewport.x) * 1.3 - viewport.x*0.15
		a.global_position.y = rand_range(-15, -130)
		a.rotation_degrees = rand_range(75, 125)
		if is_instance_valid(player):
			a.rotation = a.global_position.angle_to_point(player.global_position) + deg2rad(180)
		a.speed = rand_range(250, 280) * aggressionMultiplier
		a.init()
	$TargetingAsteroidsTimer.start(spawnTime/aggressionMultiplier)
