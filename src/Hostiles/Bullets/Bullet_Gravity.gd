extends "res://Hostiles/Bullets/Bullet_Base.gd"


var objectsToPullOn = []
export(float) var gravityStr = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	applyGravityToObjects(delta)

func _on_GravityArea_area_entered(area):
	if area.is_in_group("PlayerOuterHitbox"):
		objectsToPullOn.append(area.owner)


func _on_GravityArea_area_exited(area):
	if is_instance_valid(area.owner) and area.owner in objectsToPullOn:
		var obj = objectsToPullOn.find(area.owner)
		objectsToPullOn.remove(obj)

func applyGravityToObjects(delta):
	for obj in objectsToPullOn:
		if is_instance_valid(obj):
			var diffNormalized = (global_position - obj.global_position).normalized()
			obj.global_position += (delta*diffNormalized*gravityStr)
