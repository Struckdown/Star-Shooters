extends Node2D


onready var scoreBoardRef
onready var playerRef
export(PackedScene) var playerSpawn
export(Array, PackedScene) var waves
var waveNum = 0
var curWave = null
var score = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	scoreBoardRef = get_node("VPCscoreboard/Viewport/Scoreboard")
	playerSpawn = get_node("VPCgame/Viewport/PlayerSpawner")
	spawnNewPlayer()
	$"/root/SceneTransition".fadeinFromBlack()
	spawnWave()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(_event):
	if Input.is_action_pressed("pause"):
		$"CanvasLayer/Pause Menu".show()
		get_tree().paused = true

func updateCharge():
	scoreBoardRef.updateCharge(playerRef.energyLevel / playerRef.energyLimit)

func updateScore(newScore):
	score += newScore
	scoreBoardRef.updateScore(score)

func spawnWave():
	print("Spawning wave " + str(waveNum))
	if waveNum < waves.size():
		curWave = waves[waveNum].instance()
		$VPCgame/Viewport.add_child(curWave)
		waveNum +=1
		curWave.connect("waveFinished", self, "spawnWave")
		curWave.connect("enemyDestroyed", self, "updateScore")
	else:
		print("Tried to access index out of bounds in wave size: " + str(waveNum))
		print("TODO, play victory scene?")

func spawnNewPlayer():
	playerRef = playerSpawn.spawnPlayer()
	playerRef.connect("energyUpdated", self, "updateCharge")
	playerRef.connect("destroyed", self, "spawnNewPlayer")
	updateCharge()
