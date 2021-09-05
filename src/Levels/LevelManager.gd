extends Node2D


onready var scoreBoardRef
onready var playerRef
onready var WaveManager
var playerSpawn
var waves = []
var waveNum = 0
var curWave = null
var wavesComplete = 0
export(int) var level = 1
var levelLost = false
var levelWon = false

export(bool) var debug = false
export(int) var debugWave = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	scoreBoardRef = get_node("VPCscoreboard/Viewport/Scoreboard")
	playerSpawn = get_node("VPCgame/Viewport/PlayerSpawner")
	if GameManager.stage != null:
		level = GameManager.stage
	BGM.transitionSong("res://Levels/mixkit-space-game-668.mp3")
	spawnNewPlayer(0)
	getWaves()
	spawnWave()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _unhandled_input(_event):
	if Input.is_action_pressed("pause") and not $"CanvasLayer/Pause Menu".visible:
		$"CanvasLayer/Pause Menu".show()
		get_tree().paused = true
		get_tree().get_root().set_input_as_handled()


func getWaves():
	var levelToLoad = "res://Levels/Stages/Level" + str(level) + "/Level" + str(level) + ".tscn"
	var temp = load(levelToLoad).instance()
	waves = temp.waves

func updateCharge():
	scoreBoardRef.updateCharge(playerRef.energyLevel / playerRef.energyLimit)

func addToScore(scoreToAdd):
	GameManager.score += scoreToAdd
	scoreBoardRef.updateScore()

func spawnWave():
	if debug:
		waveNum = debugWave
	
	if waveNum < waves.size():
		curWave = waves[waveNum].instance()
		#curWave.position.y -= 200	# Have enemies spawn off camera	# Too hacky, need to come up with better alternative
		$VPCgame/Viewport.call_deferred("add_child", curWave)
		waveNum +=1
		curWave.connect("startNextWave", self, "spawnWave")
		curWave.connect("enemyDestroyed", self, "addToScore")
		curWave.connect("waveFinished", self, "updateWavesFinished")
		if curWave.usesBossHP:
			curWave.bossHPRef = $"CanvasLayer/Boss HP"
			curWave.setUpBossHP()
		else:
			$"CanvasLayer/Boss HP".hide()
	else:
		print("Ran out of waves to spawn, should be at the end here")


func updateWavesFinished():
	wavesComplete += 1
	if wavesComplete >= waves.size():
		levelWon = true
		playerRef.godMode = true
		if not levelLost:
			$"CanvasLayer/Level Won".playLevelComplete()
			$LevelWonGemCollectDelayTimer.start()
		else:
			print("Level was supposed to be won, but level lost was true first. :(")


func spawnNewPlayer(livesDelta):
	GameManager.playerLives += livesDelta
	if GameManager.playerLives >= 0:
		playerRef = playerSpawn.spawnPlayer()
		playerRef.connect("energyUpdated", self, "updateCharge")
		playerRef.connect("destroyed", self, "spawnNewPlayer", [-1])
		playerRef.connect("gemCollected", self, "gemCollected")
		updateCharge()
		if livesDelta != 0:
			scoreBoardRef.updateLives(livesDelta)
	else:
		levelLost = true
		if not levelWon:
			$"CanvasLayer/Game Over/AnimationPlayer".play("Game Over")
		else:
			print("Level was supposed to be lost, but was already won")


func gemCollected():
	addToScore(100)


func _on_LevelWonGemCollectDelayTimer_timeout():
	$VPCgame/Viewport/LevelBoundaries.collectGems(playerRef)
