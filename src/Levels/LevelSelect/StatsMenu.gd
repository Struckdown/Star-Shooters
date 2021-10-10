extends Control

signal statsClosed
var displaying = false
export(NodePath) var levels

# Called when the node enters the scene tree for the first time.
func _ready():
	calculateTotalScore()
	calculateGameCompletion()
	setUpStats()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if event.is_action_pressed("ui_cancel") and displaying:
		closeWindow()
		get_tree().get_root().set_input_as_handled()


func calculateTotalScore():	
	var totalScore = 0
	for key in GameManager.stagesCompletedData:
		totalScore += GameManager.stagesCompletedData[key]
	var prevTotalScore = StatsManager.stats["totalScore"]
	StatsManager.updateStats("totalScore", totalScore-prevTotalScore)

func calculateGameCompletion():
	var totalLevels = get_node(levels).get_child_count()
	var levelsComplete = len(GameManager.stagesCompletedData)
	var prevPercentage = StatsManager.stats["gameCompletion"]
	var percentage = float(levelsComplete) / float(totalLevels) * 100
	StatsManager.updateStats("gameCompletion", percentage-prevPercentage)


func setUpStats():
	var vBox = get_node("WindowTexture/ScrollContainer/VBoxContainer")
	var i = 0
	var statsOrder = ["enemiesKilled", "deaths", "bossesDefeated",
"lasersFired", "chargeGained", "overworldDistanceTraveled",
"timesSlipstreamed", "stagesCleared", "stagesPlayed",
"totalScore", "gemsCollected", "gameCompletion", "timePlayed",
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
		if lbl.text == "Game Completion:":
			val.text += "%"
		hBox.name = lbl.text + "hBox"
		lbl.show()
		val.show()
		hBox.add_child(lbl)
		hBox.add_child(val)
		i += 1

func prettyText(txt: String):
	var newTxt = ""
	var i = 0
	for l in txt:
		if l == l.to_upper():
			newTxt += " "
		if i == 0:
			l = l.to_upper()
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

func closeWindow():
	display(false)
	$WindowTexture/CloseButton/CloseSFX.play()
	emit_signal("statsClosed")
	$WindowTexture/CloseButton.release_focus()

func _on_SecondTimer_timeout():
	var vBox = get_node("WindowTexture/ScrollContainer/VBoxContainer")
	for child in vBox.get_children():
		if child.name == "Time PlayedhBox":
			var time = int(StatsManager.stats["timePlayed"])
			var formattedTime = convertSecondsToHHMMSS(time)
			child.get_children()[1].text = formattedTime	# TODO Consider per stat conversions (Eg, timePlayed should convert seconds to HH:MM format)


func convertSecondsToHHMMSS(seconds: int) -> String:
	var hours = int(float(seconds) / 3600.0)
	seconds %= 3600
	var minutes = int(float(seconds) / 60.0)
	seconds %= 60
	var formattedStr = "" + str(hours) + " hours, " + str(minutes) + " minutes, " + str(seconds) + " seconds"
	return formattedStr


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Display" and displaying:
		$WindowTexture/CloseButton.grab_focus()


func _on_CloseButton_button_down():
		closeWindow()
