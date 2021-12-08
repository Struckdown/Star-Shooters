extends Node2D

var active := false
var rotationSpeed = 60
var MAX_SPEED = 600
signal activated

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotation += deg2rad(rotationSpeed)*delta


func _on_Area2D_area_entered(area):
	if area.is_in_group("PlayerOuterHitbox") and not active:
		active = true
		$Tween.interpolate_property(self, "rotationSpeed", 60, MAX_SPEED, 3, Tween.TRANS_LINEAR)
		$Tween.start()


func _on_Area2D_area_exited(area):
	if area.is_in_group("PlayerOuterHitbox") and active:
		active = false
		$Tween.interpolate_property(self, "rotationSpeed", rotationSpeed, 60, 1, Tween.TRANS_LINEAR)
		$Tween.start()


func _on_Tween_tween_completed(_object, _key):
	if active:
		emit_signal("activated")
