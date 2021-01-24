extends Particles2D


var timerDelay = 2


# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.wait_time = timerDelay
	$Timer.start()


func _on_Timer_timeout():
	queue_free()
