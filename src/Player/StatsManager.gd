extends Node2D


var stats = {}
var saveFileName = "user://statsManager.save"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func updateStats(key, valueDelta):
	if key in stats:
		stats[key] = stats[key] + valueDelta
	else:
		push_error("Tried to push an invalid stat: " + key)

func saveGame():
	var save_game = File.new()
	save_game.open(saveFileName, File.WRITE)
	save_game.store_line(to_json(stats))

func load_game():
	var save_game = File.new()
	if not save_game.file_exists(saveFileName):
		print("Stats save doesn't exist, can't load anything!")
		resetToDefaults()
		return # Error! We don't have a save to load.
	save_game.open(saveFileName, File.READ)
	stats = parse_json(save_game.get_line())

func clearSaveData():
	var dir = Directory.new()
	dir.remove(saveFileName)
	resetToDefaults()

func resetToDefaults():
	stats = {"enemiesKilled": 0, "deaths": 0, "bossesDefeated": 0,
"lasersFired": 0, "chargeGained": 0, "overworldDistanceTraveled": 0,
"timesSlipstreamed": 0, "stagesCleared": 0, "stagesPlayed": 0,
"totalScore": 0, "gemsCollected": 0, "gameCompletion": 0
}