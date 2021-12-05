extends RayCast2D

export(bool) var sceneTransitionSpecificBeam = false
export(bool) var is_casting #setget set_is_casting
export(float) var laserLength := 1000
var canCauseDamage := false
export(bool) var generatesEnergy := false
var maxWidth = 10.0
var previewWidth = 2.0
export(float) var previewTime = 0.4
var timesCast = 0
var playerCheckerTimer = 0
var playerCheckerTimerInterval = 0.1
var energyAmountToGenerate = 3.0

func _ready():
	setGeneratesEnergy(generatesEnergy)
	set_is_casting(is_casting)
	cast_to = Vector2(laserLength, 0)
	set_physics_process(true)

func _process(delta):
	checkForPlayer(delta)

func _physics_process(_delta: float) -> void:
	var cast_point := cast_to
	force_raycast_update()
	$ImpactParticles.emitting = is_colliding()
	if is_colliding():
		cast_point = to_local(get_collision_point())
		$ImpactParticles.position = cast_point
		$ImpactParticles.global_rotation = get_collision_normal().angle()
	$Line2D.points[1] = cast_point
	$Area2D/CollisionShape2D.shape.extents = Vector2($Line2D.width, Vector2.ZERO.distance_to(cast_point)/2)
	$Area2D/CollisionShape2D.position = cast_point*0.5
	$BeamParticles.position = 0.5*cast_point
	#$BeamParticles.rotation = get_angle_to(cast_point)
	$BeamParticles.process_material.emission_box_extents.x = cast_point.length() *0.5

func set_target_point(targetPosition: Vector2) -> void:
	$Line2D.points[1] = targetPosition

func setGeneratesEnergy(state) -> void:
	generatesEnergy = state
	if generatesEnergy:
		modulate = Color(383.0/256.0, 102.0/256.0, 102.0/256.0, 1)
	else:
		modulate = Color(102.0/256.0, 306.0/256.0, 383.0/256.0)
	var area = $Area2D
	if not generatesEnergy and area.is_in_group("generatesEnergy"):
		area.remove_from_group("generatesEnergy")
	if generatesEnergy and not area.is_in_group("generatesEnergy"):
		area.add_to_group("generatesEnergy")

func toggleEmitting(state: bool) -> void:
	for child in get_children():
		if child.has_method("toggleEmitting"):
			child.toggleEmitting(state)
	set_is_casting(state)

func set_is_casting(cast: bool) -> void:
	timesCast += 1
	is_casting = cast
	$SourceParticles.emitting = is_casting
	if is_casting:
		appear()
	else:
		disappear()
		$ImpactParticles.emitting = false
	set_physics_process(is_casting)

func appear() -> void:
	#if sceneTransitionSpecificBeam and timesCast <= 1:
	#	return
	$AudioStreamPlayer.play()
	$Tween.stop_all()
	$Tween.interpolate_property($Line2D, "width", 0, previewWidth, previewTime)
	$Tween.start()

func disappear() -> void:
	canCauseDamage = false
	$Tween.stop_all()
	$Tween.interpolate_property($Line2D, "width", $Line2D.width, 0, 0.1)
	$Tween.start()
	$AudioStreamPlayer.stop()
	$BeamParticles.emitting = false
	$Area2D/CollisionShape2D.set_deferred("disabled", true)


func _on_Tween_tween_completed(object, _key):
	if object == $Line2D:
		if $Line2D.width == previewWidth:
			$Tween.stop_all()
			$Tween.interpolate_property($Line2D, "width", previewWidth, maxWidth, 0.2)
			$Tween.start()
			$BeamParticles.emitting = true
			$Area2D/CollisionShape2D.disabled = false
			canCauseDamage = true

func checkForPlayer(delta: float) -> void:
	playerCheckerTimer += delta
	if playerCheckerTimer < playerCheckerTimerInterval:
		return
	playerCheckerTimer = 0
	for a in $Area2D.get_overlapping_areas():
		if a.is_in_group("PlayerOuterHitbox") and a.owner.has_method("_on_EnergyArea_area_entered"):
			a.owner._on_EnergyArea_area_entered($Area2D)
