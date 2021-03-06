extends Node2D

var selectedLevel = null
onready var selectedPlanet
var mapPlayerRef

func _ready():
	for level in $Levels.get_children():
		level.connect("playerNearby", self, "updateSelectedLevel")
	$CanvasLayer/MissionBriefing.hide()
	#GameManager.load_game()
	#get_nodes_in_group()
	mapPlayerRef = get_tree().get_nodes_in_group("Player")


func _input(event):
	if event.is_action_pressed("fire"):
		if selectedLevel != null and not $CanvasLayer/MissionBriefing.visible:
			#$CanvasLayer/MissionBriefing.show()
			$CanvasLayer/MissionBriefing.playDisplayAnimation("forwards")
			for player in mapPlayerRef:
				if is_instance_valid(player): 
					player.canMove = false
			#get_tree().set_input_as_handled()
	if Input.is_action_pressed("pause") and not $"CanvasLayer/Pause Menu".visible:
		$"CanvasLayer/Pause Menu".show()
		get_tree().paused = true
		get_tree().get_root().set_input_as_handled()


# Sets the mission briefing data and what will be opened up when the action key is pressed
func updateSelectedLevel(planet):
	if planet == null:
		selectedLevel = null
	else:
		selectedLevel = planet.levelNumber
		$CanvasLayer/MissionBriefing.updateText(planet)


func _on_MissionBriefing_deploy():
	if selectedLevel != null:
		GameManager.stage = selectedLevel
		GameManager.saveGame()
		SceneTransition.transitionToScene("res://Levels/Stages/MainWorld.tscn")


func _on_MissionBriefing_cancel():
	for player in mapPlayerRef:
		if is_instance_valid(player):
			player.canMove = true
	pass#$MissionBriefing.playDisplayAnimation("backwards")

func save():
	var _save_dict = {
		#TODO
	}

