extends RayCast2D

export(bool) var sceneTransitionSpecificBeam = false
export(bool) var is_casting := false setget set_is_casting
export(float) var laserLength := 1000
var maxWidth = 10.0
var previewWidth = 2.0
export(float) var previewTime = 0.4
var timesCast = 0

func _ready():
	set_is_casting(is_casting)
	cast_to = Vector2(laserLength, 0)

func _process(_delta):
	pass

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
	#$BeamParticles.rotation = get_angle_to(cast_point)
	$BeamParticles.process_material.emission_box_extents.x = cast_point.length() *0.5

func set_target_point(targetPosition: Vector2) -> void:
	$Line2D.points[1] = targetPosition


func toggleEmitting(state: bool) -> void:
	for child in get_children():
		if child.has_method("toggleEmitting"):
			child.toggleEmitting(state)
	set_is_casting(state)

func set_is_casting(cast: bool) -> void:
	timesCast += 1
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
	if sceneTransitionSpecificBeam and timesCast <= 1:
		return
	$Tween.stop_all()
	$Tween.interpolate_property($Line2D, "width", 0, previewWidth, 0.4)
	$Tween.start()

func disappear() -> void:
	$Tween.stop_all()
	$Tween.interpolate_property($Line2D, "width", $Line2D.width, 0, previewTime)
	$Tween.start()


func _on_Tween_tween_completed(object, _key):
	if object == $Line2D:
		if $Line2D.width == previewWidth:
			$Tween.stop_all()
			$Tween.interpolate_property($Line2D, "width", previewWidth, maxWidth, 0.2)
			$Tween.start()
