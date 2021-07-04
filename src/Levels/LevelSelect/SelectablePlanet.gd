extends Node2D

export(String, MULTILINE) var levelDescription # Sector Name
var bestScore = 0
export(int) var levelNumber
signal playerNearby
export(String, MULTILINE) var missionName
export(String, MULTILINE) var missionBriefing


func _ready():
	set_description()


func set_description() -> void:
	$LevelPanel/LevelDescription.text = levelDescription + "\n" + missionName

	var scores_save = File.new()
	var saveFileName = "user://score_Level" + str(levelNumber) +".save"
	if not scores_save.file_exists(saveFileName):
		scores_save.open(saveFileName, File.WRITE)
		scores_save.store_line("0")
		bestScore = 0
	else:
		scores_save.open(saveFileName, File.READ)
		var scores = []
		while scores_save.get_position() < scores_save.get_len():
			scores.append(scores_save.get_line())
		bestScore = scores[0]	# scores are assumed to already be sorted in descending order
	
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
	var _save_dict = {
		"bestScore": bestScore
	}
