extends Node2D


var active = true


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_OuterCollision_area_entered(area):
	if area.global_position.distance_to($Inner.global_position) <= $Inner/CollisionShape2D.shape.radius*scale.x:
		return
	if area.is_in_group("Hostile"):
		area.owner.queue_free()


func _on_Inner_area_exited(area):
	if area.is_in_group("Hostile") and active:
		if is_instance_valid(area.owner):
			area.owner.queue_free()


func _on_AnimationPlayer_animation_finished(_anim_name):
	active = false
	queue_free()
