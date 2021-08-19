extends Node2D
# Contains data between levels

var score = 0
var playerLives = 3
var stage = null
var lastPlayedStage = null
var gameMode = null

func _ready():
	pass

func resetGame():
	score = 0
	playerLives = 3
	stage = null
	lastPlayedStage = null
	gameMode = null

func resetPlayerLives():
	playerLives = 3	#called whenever level select is hit?

func updateScores(newScore: int) -> void:
	var scores_save = File.new()
	var levelSaveName = "user://score_Level" + str(stage) +".save"
	scores_save.open(levelSaveName, File.READ)
	var scores = []
	while scores_save.get_position() < scores_save.get_len():
		scores.append(parse_json(scores_save.get_line()))
	scores_save.close()

	scores_save.open(levelSaveName, File.WRITE)
	scores.append(newScore)
	scores.sort()
	scores_save.seek(0)
	scores.invert()	# reverses the list to put the biggest number at the top
	var i = 0
	for s in scores:
		scores_save.store_line(to_json(s))
		i += 1
		if i >= 10:	# never store more than the 10 top scores
			break

func saveGame():
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.filename.empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue
			
		# Check the node has a save function.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue
		
		# Call the node's save function.
		var node_data = node.call("save")
		
		# Store the save dictionary as a new line in the save file.
		save_game.store_line(to_json(node_data))
	save_game.close()
	print("Game saved!")
	

func load_game():
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
		print("Game save doesn't exist, can't load anything!")
		return # Error! We don't have a save to load.
		
	# We need to revert the game state so we're not cloning objects
	# during loading. This will vary wildly depending on the needs of a
	# project, so take care with this step.
	# For our example, we will accomplish this by deleting saveable objects.
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for i in save_nodes:
		i.queue_free()
		
	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	save_game.open("user://savegame.save", File.READ)
	while save_game.get_position() < save_game.get_len():
		# Get the saved dictionary from the next line in the save file
		var node_data = parse_json(save_game.get_line())
		
		# Firstly, we need to create the object and add it to the tree and set its position.
		var new_object = load(node_data["filename"]).instance()
		get_node(node_data["parent"]).add_child(new_object)
		new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])
		
		# Now we set the remaining variables.
		for i in node_data.keys():
			if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
				continue
			new_object.set(i, node_data[i])
	
	save_game.close()
	print("Game loaded")
