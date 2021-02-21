extends Panel


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func updateCharge(charge):
	$VBoxContainer/ChargeBar.material.set_shader_param("FillPercentage", charge)


func updateScore(score):
	$VBoxContainer/ScoreLbl.text = "SCORE\n{scoreText}".format({"scoreText":"%06d" % score})
