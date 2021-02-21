extends Node2D
#Controls how the wave behaves and when it's considered "defeated"

var enemies
signal waveFinished
signal enemyDestroyed

# Called when the node enters the scene tree for the first time.
func _ready():
	enemies = get_child_count()
	for e in get_children():
		e.connect("destroyed", self, "updateEnemyCount")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func updateEnemyCount(pointsWorth):
	enemies -= 1
	emit_signal("enemyDestroyed", pointsWorth)
	if enemies <= 0:
		emit_signal("waveFinished")
