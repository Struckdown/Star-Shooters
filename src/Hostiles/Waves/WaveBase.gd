extends Node2D
#Controls how the wave behaves and when it's considered "defeated"

var enemiesDestroyed = 0
var enemies = []
var initialAmountOfEnemies
export(String, "enemies", "time", "other") var waveAdvanceCondition = "enemies"
export(int) var enemiesToDestroy = 0
export(int) var timeToNextWave
export(bool) var usesBossHP = false	# level manager uses this to connect this to the enemy
export(String) var bossName = ""
export(String) var musicRequest = ""
var bossHPRef
var waveFinishedSignalEmitted = false
signal waveFinished
signal startNextWave
signal enemyDestroyed

# Called when the node enters the scene tree for the first time.
func _ready():
	var children = get_children()
	for child in children:
		if child.has_signal("destroyed"):
			#actualEnemies += 1
			child.connect("destroyed", self, "updateEnemyCount")
			enemies.append(child)
	initialAmountOfEnemies = len(enemies)
	setupAdvanceCondition()
	if musicRequest != "":
		changeMusic()


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
			if enemiesToDestroy == 0:
				enemiesToDestroy = initialAmountOfEnemies	# set enemies to max enemies if unset
		"time":
			var timer = Timer.new()
			add_child(timer)
			timer.connect("timeout", self, "advanceWave")
			timer.set_wait_time(timeToNextWave)
			timer.one_shot = true
			timer.start()
		"other":
			otherAdvanceCondition()

func otherAdvanceCondition():
	pass	# To be overwritten in subclasses

func setUpBossHP():	# used by level manager
	var hpTotal = 0
	for child in get_children():
		if child.has_signal("destroyed"):
			hpTotal += child.maxHealth
			child.setHealthBarRef(bossHPRef)
	
	bossHPRef.setup(hpTotal, bossName)
	

func updateEnemyCount(pointsWorth):
	enemiesDestroyed += 1
	emit_signal("enemyDestroyed", pointsWorth)
	if enemiesDestroyed >= enemiesToDestroy and waveAdvanceCondition == "enemies":	# trigger if count met
		advanceWave()
	if enemiesDestroyed >= initialAmountOfEnemies:
		markWaveFinished()
		queue_free()
	
func advanceWave():	# lets the wave manager know it can start the next wave
	if not waveFinishedSignalEmitted:
		emit_signal("startNextWave")
		waveFinishedSignalEmitted = true

func markWaveFinished():	# needed for counting amount of waves finished so wave manager knows to end the level
	advanceWave()	# if for some reason the wave was cleared before it was advanced (eg, killing enemies before time ran out), advance it
	emit_signal("waveFinished")

func changeMusic():
	BGM.transitionSong(musicRequest)
