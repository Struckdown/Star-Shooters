extends RayCast2D

var is_casting := false setget set_is_casting

func _ready():
	pass
#	set_physics_process(true)
#	$Line2D.points[1] = Vector2.ZERO
	
func _input(_event: InputEvent) -> void:
	pass#if event is InputEventMouseButton:
	#	self.is_casting = event.pressed
	#	cast_to = get_local_mouse_position()
	#	print("Casting!?")

func _process(_delta):
	pass
	#cast_to = get_local_mouse_position()

func _physics_process(_delta: float) -> void:
	var cast_point := cast_to
	force_raycast_update()
	$ImpactParticles.emitting = is_colliding()
	if is_colliding():
		cast_point = to_local(get_collision_point())
		$ImpactParticles.position = cast_point
		$ImpactParticles.global_rotation = get_collision_normal().angle()
	$Line2D.points[1] = cast_point
	$BeamParticles.position = 0.5*cast_point
	$BeamParticles.process_material.emission_box_extents.x = cast_point.length() *0.5

func set_is_casting(cast: bool) -> void:
	is_casting = cast
	
	$BeamParticles.emitting = is_casting
	$SourceParticles.emitting = is_casting
	if is_casting:
		appear()
	else:
		disappear()
		$ImpactParticles.emitting = false
	set_physics_process(is_casting)

func appear() -> void:
	$Tween.stop_all()
	$Tween.interpolate_property($Line2D, "width", 0, 10.0, 0.2)
	$Tween.start()

func disappear() -> void:
	$Tween.stop_all()
	$Tween.interpolate_property($Line2D, "width", 10.0, 0, 0.1)
	$Tween.start()
