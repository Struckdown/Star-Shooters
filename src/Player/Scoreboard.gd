extends Panel

var firstUpdate = true
var livesCount

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.resetPlayerLives()
	livesCount = GameManager.playerLives
	updateLives(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func updateCharge(charge):
	$VBoxContainer/ChargeBar.material.set_shader_param("FillPercentage", charge)

func updateScore():
	$VBoxContainer/ScoreLbl.text = "SCORE\n{scoreText}".format({"scoreText":"%06d" % GameManager.score})

func updateLives(livesDelta):
	livesCount += livesDelta
	for life in $VBoxContainer/VBoxContainer/CenterContainer/LivesHBoxContainer.get_children():
		if int(life.name[-1]) >= livesCount:
			life.disappear()
			if firstUpdate:
				life.hide()
	firstUpdate = false
