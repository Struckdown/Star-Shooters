extends Control

signal statsClosed
var displaying

# Called when the node enters the scene tree for the first time.
func _ready():
	setUpStats()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if event.is_action_pressed("ui_cancel") and displaying:
		closeWindow()
		get_tree().get_root().set_input_as_handled()
		

func setUpStats():
	var vBox = get_node("WindowTexture/ScrollContainer/VBoxContainer")
	var i = 0
	var statsOrder = ["enemiesKilled", "deaths", "bossesDefeated",
"lasersFired", "chargeGained", "overworldDistanceTraveled",
"timesSlipstreamed", "stagesCleared", "stagesPlayed",
"totalScore", "gemsCollected", "gameCompletion"
]

	var hBox = null
	for stat in statsOrder:
		if i%2 == 0:
			hBox = HBoxContainer.new()
			vBox.add_child(hBox)
		var lbl = $StatsLblSample.duplicate()
		var val = $StatsValSample.duplicate()
		lbl.text = prettyText(str(stat)) + ":"
		val.text = str(StatsManager.stats[stat])
		lbl.show()
		val.show()
		hBox.add_child(lbl)
		hBox.add_child(val)
		i += 1
	#$WindowTexture/ScrollContainer/VBoxContainer/HBoxContainer/EnemiesKilledVal.text = StatsManager.stats["enemiesKilled"]

func prettyText(txt: String):
	var newTxt = ""
	var i = 0
	for l in txt:
		if i == 0:
			l = l.to_upper()
		if l == l.to_upper():
			newTxt += " "
		newTxt += l
		i += 1
	return newTxt


func display(shouldDisplay):
	if displaying == shouldDisplay:
		return
	displaying = shouldDisplay
	if shouldDisplay:
		$AnimationPlayer.play("Display")
	else:
		$AnimationPlayer.play_backwards("Display")

func _on_CloseButton_button_up():
	closeWindow()

func closeWindow():
	display(false)
	$WindowTexture/CloseButton/CloseSFX.play()
	emit_signal("statsClosed")
	$WindowTexture/CloseButton.release_focus()
