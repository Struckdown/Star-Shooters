extends Node2D

var selectedLevel = null

func _ready():
	for level in $Levels.get_children():
		level.connect("playerNearby", self, "updateSelectedLevel")
	$CanvasLayer/MissionBriefing.hide()



func _input(event):
	if event.is_action_pressed("fire"):
		if selectedLevel != null and not $CanvasLayer/MissionBriefing.visible:
			#$CanvasLayer/MissionBriefing.show()
			$CanvasLayer/MissionBriefing.playDisplayAnimation("forwards")
			$MapPlayer.canMove = false
			#get_tree().set_input_as_handled()


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
	$MapPlayer.canMove = true
	pass#$MissionBriefing.playDisplayAnimation("backwards")
