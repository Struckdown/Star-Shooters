extends Node2D
#Controls how the wave behaves and when it's considered "defeated"

var enemiesDestroyed = 0
var enemies
export(String, "enemies", "time", "other") var waveAdvanceCondition = "enemies"
export(int) var enemiesToDestroy = 0
export(int) var timeToNextWave
var waveFinishedSignalEmitted = false
signal waveFinished
signal enemyDestroyed

# Called when the node enters the scene tree for the first time.
func _ready():
	enemies = get_children()
	setupAdvanceCondition()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# Controls what marks this wave as complete
# Enemies = enough foes are destroyed
# Time = enough time has passed
# Other = TBD, maybe tutorial or dialogue?
func setupAdvanceCondition():
	match waveAdvanceCondition:
		"enemies":
			for e in enemies:
				e.connect("destroyed", self, "updateEnemyCount")
			if enemiesToDestroy == 0:
				enemiesToDestroy = len(enemies)	# set enemies to max enemies if unset
		"time":
			var timer = Timer.new()
			add_child(timer)
			timer.connect("timeout", self, "advanceWave")
			timer.set_wait_time(timeToNextWave)
			timer.one_shot = true
			timer.start()
		"other":
			pass	#TODO? Not sure what to put here, maybe something with other objects calling this one to advance the wave?

func updateEnemyCount(pointsWorth):
	enemiesDestroyed += 1
	emit_signal("enemyDestroyed", pointsWorth)
	if enemiesDestroyed >= enemiesToDestroy:	# trigger if count met or no more enemies remain
		advanceWave()
	if enemiesDestroyed >= len(enemies):
		advanceWave()
		queue_free()
	
func advanceWave():
	if not waveFinishedSignalEmitted:
		emit_signal("waveFinished")
		waveFinishedSignalEmitted = true
