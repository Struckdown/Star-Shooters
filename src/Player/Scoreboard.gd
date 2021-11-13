extends Panel

var firstUpdate = true
var livesCount

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.resetPlayerLives()
	livesCount = GameManager.playerLives
	updateLives(0)
	updateFireType()
	var err = GameManager.connect("fireModeUpdated", self, "updateFireType")
	if err:
		print("Error:", err)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func updateCharge(charge):
	$VBoxContainer/MarginContainer/ChargeBar.material.set_shader_param("FillPercentage", charge)

func updateScore():
	
	$VBoxContainer/ScoreLbl.text = "SCORE\n{scoreText}".format({"scoreText":"%06d" % min(GameManager.score, 999999)})

func updateLives(livesDelta):
	livesCount += livesDelta
	for life in $VBoxContainer/VBoxContainer/CenterContainer/LivesHBoxContainer.get_children():
		if int(life.name[-1]) >= livesCount:
			life.disappear()
			if firstUpdate:
				life.hide()
	firstUpdate = false

func updateFireType():
	var finalStr = "Fire Mode: "
	var newTexture = "Blue"
	match GameManager.playerFireType:
		GameManager.playerFireTypes.FOCUSED:
			finalStr += "Focused"
			newTexture = "Blue"
		GameManager.playerFireTypes.CHARGE:
			finalStr += "Heavy"
			newTexture = "Red"
		GameManager.playerFireTypes.REVERSE:
			finalStr += "Reverse"
			newTexture = "Yellow"
		GameManager.playerFireTypes.SPREAD:
			finalStr += "Spread"
			newTexture = "Green"
	$VBoxContainer/HBoxContainer/FireModeLbl.text = finalStr
	$VBoxContainer/HBoxContainer/FireTypeTexture.texture = load("res://Space Shooter Redux/PNG/Power-ups/powerup" + newTexture +"_bolt.png")
