extends Particles2D


var timerDelay = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	$AudioStreamPlayer.pitch_scale = rand_range(0.75, 2)
	$Timer.wait_time = timerDelay
	$Timer.start()


func _on_Timer_timeout():
	queue_free()

func play():
	emitting = true
	$AudioStreamPlayer.play()
