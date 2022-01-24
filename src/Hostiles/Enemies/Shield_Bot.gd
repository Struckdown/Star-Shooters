extends "res://Hostiles/Enemies/Enemy_Base.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.


func assignTarget(newTarget):
	target = newTarget
	print(target.name)
	if is_instance_valid(target):
		for child in $Particles.get_children():
			child.look_at(target.global_position)
		
