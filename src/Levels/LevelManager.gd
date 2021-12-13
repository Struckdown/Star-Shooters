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
onready var camera = $VPCgame/Viewport/Camera2D
var shakeIntensity = 0	# from 0 to 1
onready var dialogueBoxRef = $CanvasLayer/DialogueBox

export(bool) var debug = false
export(int) var debugWave = 0
export(String) var debugWaveName

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	scoreBoardRef = get_node("VPCscoreboard/Viewport/Scoreboard")
	playerSpawn = get_node("VPCgame/Viewport/PlayerSpawner")
	if GameManager.stage != null:
		level = GameManager.stage
	setupLevelSpecificFeatures()
	BGM.transitionSong("res://Levels/mixkit-space-game-668.mp3")
	spawnNewPlayer(0)
	getWaves()
	spawnWave()
	StatsManager.updateStats("stagesPlayed", 1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	updateCameraShake()

func _unhandled_input(_event):
	if Input.is_action_pressed("pause") and not $"CanvasLayer/Pause Menu".visible:
		$"CanvasLayer/Pause Menu".show()
		get_tree().paused = true
		get_tree().get_root().set_input_as_handled()


func getWaves():
	var levelToLoad = "res://Levels/Stages/Level" + str(level) + "/Level" + str(level) + ".tscn"
	var temp = load(levelToLoad).instance()
	waves = temp.waves

func addWave(newScene):
	waves.append(newScene)

func updateCharge():
	scoreBoardRef.updateCharge(playerRef.energyLevel / playerRef.energyLimit)

func addToScore(scoreToAdd):
	GameManager.score += scoreToAdd
	scoreBoardRef.updateScore()

func spawnWave():
	#print("Spawned wave: ", waveNum, " out of ", waves.size())
	if debug:
		waveNum = debugWave
		if debugWaveName != null:
			waves.append(load(debugWaveName))
			waveNum = waves.size()-1
	
	if waveNum < waves.size():
		curWave = waves[waveNum].instance()
		waveNum +=1
		$VPCgame/Viewport.call_deferred("add_child", curWave)
		curWave.connect("startNextWave", self, "spawnWave")
		curWave.connect("enemyDestroyed", self, "addToScore")
		curWave.connect("waveFinished", self, "updateWavesFinished")
		curWave.bossHPRef = $"CanvasLayer/Boss HP"
		curWave.arrowTrackerRef = $VPCgame/Viewport/EnemyArrowTrackerManager
		curWave.startArrowTracking()
		curWave.dialogueBoxRef = dialogueBoxRef
		if curWave.dialogueRequest:
			yield(get_tree().create_timer(curWave.dialogueRequestDelay), "timeout")
			if curWave.waveAdvanceCondition == "dialogue":
				dialogueBoxRef.connect("finished", curWave, "markWaveFinished")
			dialogueBoxRef.setUpNewSequence(curWave.dialogueRequest)

	else:
		pass
		#print("Ran out of waves to spawn, should be at the end here")


func updateWavesFinished():
	wavesComplete += 1
	if wavesComplete >= waves.size():
		levelWon = true
		if is_instance_valid(playerRef):
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

func updateCameraShake():
	var x = (randi()%2*2-1) * shakeIntensity
	var y = (randi()%2*2-1) * shakeIntensity
	camera.offset = Vector2(x, y)
	shakeIntensity *= 0.95

func addCameraShakeIntensity(val):
	shakeIntensity += val

func setupLevelSpecificFeatures():
	match level:
		6:
			var bg = get_tree().get_nodes_in_group("Background")[0]
			bg.backgroundSpeedMultiplier = 8


func _on_Game_Over_gameOverAnimationFinished():
	$CanvasLayer/Control/RetryMenu.display()
	

func _on_RetryMenu_retry():
	GameManager.skipDialogue = true
	SceneTransition.transitionToScene("res://Levels/Stages/MainWorld.tscn")	# all the properties should already be set, so this should reload the level


func _on_RetryMenu_backToMap():
	SceneTransition.transitionToScene("res://Levels/LevelSelect/LevelSelect.tscn")
