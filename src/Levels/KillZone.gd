extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_Area2D_area_entered(area):
	if area.is_in_group("Hostile") or area.is_in_group("Enemy"):
		area.owner.queue_free()
