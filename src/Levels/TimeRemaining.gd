extends Control

export(int) var minutes
export(int) var seconds
var remainingTime

# Called when the node enters the scene tree for the first time.
func _ready():
	seconds += minutes*60
	remainingTime = float(seconds)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	remainingTime -= delta
	updateLbl()


func updateLbl():
	var m = int(remainingTime / 60)
	var s = int(remainingTime) % 60
	s = max(s, 0)
	s = "%02d" % s
	var output = str(m) + ":" + str(s)
	$TimeLbl.text = output
