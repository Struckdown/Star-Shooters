extends Node2D


onready var scoreBoardRef
onready var playerRef
onready var WaveManager
var playerSpawn
var waves = []
var waveNum = 0
var curWave = null
export(int) var level = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	scoreBoardRef = get_node("VPCscoreboard/Viewport/Scoreboard")
	playerSpawn = get_node("VPCgame/Viewport/PlayerSpawner")
	spawnNewPlayer(0)
	getWaves()
	spawnWave()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _unhandled_input(event):
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
	print("Spawning wave " + str(waveNum))
	if waveNum < waves.size():

		curWave = waves[waveNum].instance()
		curWave.position.y -= 200	# Have enemies spawn off camera
		$VPCgame/Viewport.call_deferred("add_child", curWave)
		waveNum +=1
		curWave.connect("waveFinished", self, "spawnWave")
		curWave.connect("enemyDestroyed", self, "addToScore")
	else:
		$"CanvasLayer/Level Won".playLevelComplete()

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
		$"CanvasLayer/Game Over/AnimationPlayer".play("Game Over")
		
func gemCollected():
	addToScore(100)
