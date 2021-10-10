extends Node2D
# Contains data between levels

var score = 0
var playerLives = 3
var stage = null
var stagesCompletedData = {}
var lastPlayedStage = null
var gameMode = null
var mapPlayerLastPos = Vector2(496.063, 303.194)
var mapPlayerLastRot = 0
var gameSpeed = 1	#1 is normal speed

var saveGameFileName = "user://savegame.save"

func _ready():
	load_game()
	

func clearSaveData():
	score = 0
	stage = null
	stagesCompletedData = {}
	lastPlayedStage = null
	gameMode = null
	mapPlayerLastPos = Vector2(496.063, 303.194)
	mapPlayerLastRot = 0

func resetPlayerLives():
	var curLevel = UpgradeManager.upgrades["lives"]["curLevel"]
	playerLives = UpgradeManager.upgrades["lives"]["upgradeLevels"][curLevel]	#called whenever level select is hit?


func updateStagesCompleted(level:String, newScore:int):	# level is an int converted to a string
	if level in stagesCompletedData:
		stagesCompletedData[level] = max(newScore, stagesCompletedData[level])
	else:
		stagesCompletedData[level] = newScore
	saveGame()


func saveGame():
	UpgradeManager.saveGame()
	StatsManager.saveGame()
	var save_game = File.new()
	save_game.open(saveGameFileName, File.WRITE)
	save_game.store_line(to_json(stagesCompletedData))
	save_game.store_var(mapPlayerLastPos)
	save_game.store_var(mapPlayerLastRot)
	return

#	var save_nodes = get_tree().get_nodes_in_group("Persist")
#	for node in save_nodes:
#		# Check the node is an instanced scene so it can be instanced again during load.
#		if node.filename.empty():
#			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
#			continue
#
#		# Check the node has a save function.
#		if !node.has_method("save"):
#			print("persistent node '%s' is missing a save() function, skipped" % node.name)
#			continue
#
#		# Call the node's save function.
#		var node_data = node.call("save")
#
#		# Store the save dictionary as a new line in the save file.
#		save_game.store_line(to_json(node_data))
#	save_game.close()
#	print("Game saved!")
	

func load_game():
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
#	# We need to revert the game state so we're not cloning objects
#	# during loading. This will vary wildly depending on the needs of a
#	# project, so take care with this step.
#	# For our example, we will accomplish this by deleting saveable objects.
#	var save_nodes = get_tree().get_nodes_in_group("Persist")
#	for i in save_nodes:
#		i.queue_free()
#
#	# Load the file line by line and process that dictionary to restore
#	# the object it represents.
#	save_game.open("user://savegame.save", File.READ)
#	while save_game.get_position() < save_game.get_len():
#		# Get the saved dictionary from the next line in the save file
#		var node_data = parse_json(save_game.get_line())
#
#		# Firstly, we need to create the object and add it to the tree and set its position.
#		var new_object = load(node_data["filename"]).instance()
#		get_node(node_data["parent"]).add_child(new_object)
#		new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])
#
#		# Now we set the remaining variables.
#		for i in node_data.keys():
#			if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
#				continue
#			new_object.set(i, node_data[i])
#
#	save_game.close()
#	print("Game loaded")
