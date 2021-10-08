extends "res://Hostiles/Waves/WaveBase.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()
	position = get_viewport_rect().size/2
	$CenterContainer/VBoxContainer/BossApproachingLbl.rect_pivot_offset = $CenterContainer/VBoxContainer/BossApproachingLbl.rect_size/2


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func otherAdvanceCondition():
	pass	# marked by anim player finishing


func _on_AnimationPlayer_animation_finished(_anim_name):
	markWaveFinished()
	queue_free()
