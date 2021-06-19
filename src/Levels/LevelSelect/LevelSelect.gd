extends Node2D

var selectedLevel = null

func _ready():
	for level in $Levels.get_children():
		level.connect("playerNearby", self, "updateSelectedLevel")



func _input(event):
	if event.is_action("fire"):
		if selectedLevel != null:
			$MissionBriefing.playDisplayAnimation("forwards")

# Sets the mission briefing data and what will be opened up when the action key is pressed
func updateSelectedLevel(planet):
	if planet == null:
		selectedLevel = null
	else:
		selectedLevel = planet.levelNumber


func _on_MissionBriefing_deploy():
	if selectedLevel != null:
		GameManager.stage = selectedLevel
		SceneTransition.transitionToScene("res://Levels/Stages/MainWorld.tscn")


func _on_MissionBriefing_cancel():
	pass#$MissionBriefing.playDisplayAnimation("backwards")
