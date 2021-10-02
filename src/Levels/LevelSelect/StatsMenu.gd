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

func _on_CloseButton_button_up():
	closeWindow()

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
	var hours = seconds / 3600
	#print(seconds)
	seconds %= 3600
	var minutes = seconds / 60
	seconds %= 60
	var formattedStr = "" + str(hours) + " hours, " + str(minutes) + " minutes, " + str(seconds) + " seconds"
	print(formattedStr)
	return formattedStr
