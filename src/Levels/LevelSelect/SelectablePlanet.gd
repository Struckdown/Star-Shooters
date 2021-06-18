extends Node2D

export(String, MULTILINE) var levelDescription
export(int) var levelNumber

func _ready():
	set_description(levelDescription)


func set_description(text):
	$LevelPanel/LevelDescription.text = text

func _on_Area2D_area_entered(area):
	if area.owner.is_in_group("Player"):
		area.owner.selectedLevel = levelNumber


func _on_Area2D_area_exited(area):
	if area.owner.is_in_group("Player"):
		area.owner.selectedLevel = null
