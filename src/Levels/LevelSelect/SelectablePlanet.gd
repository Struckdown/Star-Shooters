extends Node2D

export(String, MULTILINE) var levelDescription # Sector Name
var bestScore = 0
export(int) var levelNumber
signal playerNearby
export(String, MULTILINE) var missionName
export(String, MULTILINE) var missionBriefing


func _ready():
	set_description()


func set_description():
	$LevelPanel/LevelDescription.text = levelDescription + "\n" + missionName
	$LevelPanel/BestScoreLbl.text = "Best Score: " + str(bestScore)

func _on_Area2D_area_entered(area):
	if area.owner.is_in_group("Player"):
		emit_signal("playerNearby", self)


func _on_Area2D_area_exited(area):
	if area.owner.is_in_group("Player"):
		emit_signal("playerNearby", null)


func _on_DisplayArea2D_area_entered(area):
	if area.owner.is_in_group("Player"):
		$AnimationPlayer.play("DisplayLevelInfo")



func _on_DisplayArea2D_area_exited(area):
	if area.owner.is_in_group("Player"):
		$AnimationPlayer.play_backwards("DisplayLevelInfo")

#TODO
func loadScore():
	var save_dict = {
		"bestScore": bestScore
	}
