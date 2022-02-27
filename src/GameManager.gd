extends Node2D
# Contains data between levels

var score = 0
var playerLives = 3
var stage = null	# String
var stagesCompletedData = {} 	# string->array map
var lastPlayedStage = null	 #string
enum gamesModes{STORY,BOSSRUSH,INFINITE,TUTORIAL}
var gameMode = gamesModes.STORY	# enum
var mapPlayerLastPos = Vector2(496.063, 303.194)
var mapPlayerLastRot = 0
var gameSpeed = 1	#1 is normal speed
var instaKillMode = false
var skipDialogue = -1	# what wave to skip dialogue upto (and including). Set on game over to waveNum and reset on level select entered
enum playerFireTypes{SPREAD,CHARGE,FOCUSED,REVERSE}
var playerFireType = playerFireTypes.FOCUSED
var unlockedPlayerFireTypes = [playerFireTypes.FOCUSED]
var endingToPlay = "commanderVictory"	# or federationVictory. Set by final boss decision wave
var debugMode = false
var config = ConfigFile.new()
var graphicSettings = {"usesGlow": true, "BackgroundParallaxEnabled": true, "enemyParticlesEnabled": true}

var saveGameFileName = "user://savegame.save"
var optionsFileName = "user://player.perfs"
signal fireModeUpdated
signal controlsChanged
signal graphicsUpdated

func _unhandled_input(event):
	if event.is_action_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen

func _ready():
	load_game()
	

func clearSaveData():
	score = 0
	stage = null
	stagesCompletedData = {}
	lastPlayedStage = null
	mapPlayerLastPos = Vector2(496.063, 303.194)
	mapPlayerLastRot = 0
	unlockedPlayerFireTypes = [playerFireTypes.FOCUSED]; playerFireType = playerFireTypes.FOCUSED

func resetPlayerLives():
	if "lives" in UpgradeManager.upgrades:
		var curLevel = UpgradeManager.upgrades["lives"]["curLevel"]
		playerLives = UpgradeManager.upgrades["lives"]["upgradeLevels"][curLevel]	#called whenever level select is hit?
	else:
		playerLives = 3


func updateStagesCompleted(level:String, newScore:int):	# level is an int converted to a string
	if level in stagesCompletedData:
		stagesCompletedData[level] = max(newScore, stagesCompletedData[level])
	else:
		stagesCompletedData[level] = newScore
	saveGame()
	resetScore()	# Maybe find better place to reset score?

func resetScore():
	score = 0

func saveGame():
	UpgradeManager.saveGame()
	StatsManager.saveGame()
	var save_game = File.new()
	save_game.open(saveGameFileName, File.WRITE)
	save_game.store_line(to_json(stagesCompletedData))
	save_game.store_var(mapPlayerLastPos)
	save_game.store_var(mapPlayerLastRot)
	save_game.store_var(unlockedPlayerFireTypes)
	save_game.close()
	return

func load_game():
	loadSettings()
	UpgradeManager.load_game()
	StatsManager.load_game()
	var save_game = File.new()
	if not save_game.file_exists(saveGameFileName):
		print("Game save doesn't exist, can't load anything!")
		return # Error! We don't have a save to load.
	save_game.open(saveGameFileName, File.READ)
	stagesCompletedData = parse_json(save_game.get_line())
	mapPlayerLastPos = save_game.get_var()
	mapPlayerLastRot = save_game.get_var()
	unlockedPlayerFireTypes = save_game.get_var()
	save_game.close()

func saveConfig():
	#for action in InputMap.get_actions():
		#config.set_value("input", action, InputMap.get_action_list(action)[0])
	config.save(optionsFileName)

func switchToNextFireMode():
	var index = unlockedPlayerFireTypes.find(playerFireType)
	index = (index + 1) % len(unlockedPlayerFireTypes)
	playerFireType = unlockedPlayerFireTypes[index]
	emit_signal("fireModeUpdated")

# Forcibly set to a specific fire type
func updateFireMode(newType):
	match newType:
		GameManager.playerFireTypes.FOCUSED:
			playerFireType = newType
		GameManager.playerFireTypes.CHARGE:
			playerFireType = newType
		GameManager.playerFireTypes.REVERSE:
			playerFireType = newType
		GameManager.playerFireTypes.FOCUSED:
			playerFireType = newType
		_:
			print("Tried to set an invalid fire mode!")
			return
	emit_signal("fireModeUpdated")

func unlockFireMode(fireMode) -> void:
	if not (fireMode in unlockedPlayerFireTypes) and fireMode >= 0:
		unlockedPlayerFireTypes.append(fireMode)
		saveGame()

func setGameMode(newGameMode:int) -> void:
	if newGameMode >= len(gamesModes) or newGameMode < 0:
		push_error("Tried to pass invalid game mode:" + str(newGameMode))
		return
	gameMode = newGameMode

func loadSettings():
	var err = config.load(optionsFileName)
	if not err:	# if file exists, try to load it
		var bgm = config.get_value("audio", "BGM", -10.0)	# -10 is default if this value is missing for some reason
		var sfx = config.get_value("audio", "SFX", -10.0)
		gameSpeed = config.get_value("gameplay", "speed", 1)
		instaKillMode = config.get_value("gameplay", "instakill", false)
		setBusAudio("BGM", bgm)
		setBusAudio("SFX", sfx)
		
		# Set Graphics
		graphicSettings["usesGlow"] = config.get_value("graphics", "glowEnabled", true)
		graphicSettings["BackgroundParallaxEnabled"] = config.get_value("graphics", "BackgroundParallaxEnabled", true)
		graphicSettings["enemyParticlesEnabled"] = config.get_value("graphics", "enemyParticlesEnabled", true)
		GlobalWorldEnvironment.environment.glow_enabled = graphicSettings["usesGlow"]
		
		
		# Set Inputs
		for action in InputMap.get_actions():
			var scannedCode = config.get_value("input", action, 0).scancode
			if scannedCode in [null, 0]:
				continue
			var inputEventKey = InputEventKey.new()
			inputEventKey.scancode = scannedCode
			InputMap.action_erase_events(action)	# clean up old actions
			InputMap.action_add_event(action, inputEventKey)
	else:
		print("No settings configured, loading defaults")
		resetControls()

func setBusAudio(bus, value):
	var val = value#BGM.normalizeValToDB(value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), val)
	config.set_value("audio", bus, val)
	config.save(optionsFileName)

func getActionString(action): 
	return config.get_value("input", action, null)

func resetControls():
	InputMap.load_from_globals()
	emit_signal("controlsChanged")
	for action in InputMap.get_actions():
		config.set_value("input", action, InputMap.get_action_list(action)[0])
	config.save(optionsFileName)

func updateGraphicSettings(key, value):
	graphicSettings[key] = value
	config.set_value("graphics", key, value)
	config.save(optionsFileName)
	emit_signal("graphicsUpdated")
