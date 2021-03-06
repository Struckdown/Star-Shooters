extends Node2D

var waves = []
var waveNum = 0
var curWave = null

signal waveSpawned
signal enemyDestroyed
signal outOfWaves

func _ready():
	var dir = Directory.new()
	dir.open("res://Levels/Stages/Level1/")
	dir.list_dir_begin()
	
	while true:
		var file = dir.get_next()
		if file == "":
			break
		waves.append(file)

func spawnWave():
	if waveNum < waves.size():
		curWave = waves[waveNum].instance()
		curWave.position.y -= 200	# Have enemies spawn off camera
#		$VPCgame/Viewport.call_deferred("add_child", curWave)
		emit_signal("waveSpawned")
		waveNum +=1
		curWave.connect("waveFinished", self, "spawnWave")
		curWave.connect("enemyDestroyed", self, "registerEnemyDestroyed")
	else:
		emit_signal("outOfWaves")
#		$"CanvasLayer/Level Won".playLevelComplete()


func registerEnemyDestroyed():
	emit_signal("enemyDestroyed")
