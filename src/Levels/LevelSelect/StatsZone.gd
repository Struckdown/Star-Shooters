extends Node2D


signal playerNearby


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

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
