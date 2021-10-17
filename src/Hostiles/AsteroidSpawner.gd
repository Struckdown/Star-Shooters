extends Node2D

var asteroid = preload("res://Hostiles/Enemies/Asteroid.tscn")
var aggressionMultiplier = 1.0
var asteroidSpawnValue = 0
var spawnTime = 1.0
var totalDelta = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	totalDelta += delta


func _on_SpeedAsteroidTimer_timeout():
	var a = asteroid.instance()
	add_child(a)
	var viewport = get_viewport_rect().size
	a.position.x = rand_range(0, viewport.x)
	a.position.y = -15
	a.rotation_degrees = rand_range(75, 125)
	a.velocity = Vector2(1,0).rotated(a.rotation)
	$SpeedAsteroidTimer.start(spawnTime/aggressionMultiplier)

func _on_LargeGroupAsteroidTimer_timeout():
	for _i in range(int(15*aggressionMultiplier)):
		var a = asteroid.instance()
		add_child(a)
		var viewport = get_viewport_rect().size
		a.position.x = rand_range(0, viewport.x)
		a.position.y = rand_range(-15, -120)
		a.rotation_degrees = rand_range(75, 125)
		a.velocity = Vector2(1,0).rotated(a.rotation)
		a.speed = rand_range(20, 50)
		$LargeGroupAsteroidTimer.start(10/aggressionMultiplier)
