extends Node2D


var gems = 125 setget setGems
var UIref = null
var upgrades = {}	# contains "upgradeName": {"curLevel":0, "upgradeLevels":[0, 10, 20, 30, 40, 50], "startingCost": 100, }. Populated by upgrade items
# Upgrades so far: respawn energy, energy cap, energy gain, magnet radius
var saveFileName = "user://upgradeManager.save"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass	# loaded by upgradeManager

func _input(event):
	if GameManager.debugMode and event is InputEventKey and event.is_pressed():
		if event.scancode == KEY_F:
			setGems(9999999)
			print("Upgrade Manager: Cheat gems acquired")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func setGems(_val):
	gems = _val
	if UIref:
		UIref.updateVisuals()


func saveGame():
	var save_game = File.new()
	save_game.open(saveFileName, File.WRITE)
	save_game.store_var(upgrades)
	save_game.store_var(gems)
	save_game.close()

	

func load_game():
	var save_game = File.new()
	if not save_game.file_exists(saveFileName):
		print("Upgrade save doesn't exist, can't load anything!")
		return # Error! We don't have a save to load.
	save_game.open(saveFileName, File.READ)
	upgrades = save_game.get_var()
	gems = save_game.get_var()
	save_game.close()

func clearSaveData():
	var dir = Directory.new()
	dir.remove(saveFileName)
	resetToDefaults()

func resetToDefaults():
	upgrades = {}
	gems = 125
