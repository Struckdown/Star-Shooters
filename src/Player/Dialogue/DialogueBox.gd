extends Control

onready var lbl = $DialogueBoxBackground/MarginContainer/HBoxContainer/VBoxContainer/RichText
onready var nameLbl = $DialogueBoxBackground/MarginContainer/HBoxContainer/VBoxContainer/NameLbl
var filePath = "res://Player/Dialogue/dialogue.json"
var txtDictionary
var dialogueIndex = 0
var currentTextScene = []
var charactersToShowPerSecond = 40
var characterUpdatingAllowed = false
var visibleCharacters = 0.0
export(bool) var debug = false
var allTextShown = false
var textVariables = {
	"playerName": "SampleVariableName"
}

signal finished

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	var file = File.new()
	file.open(filePath, File.READ)
	txtDictionary = file.get_as_text()
	file.close()
	var err = JSON.parse(txtDictionary)
	if err.result == null:
		print(err)
	txtDictionary = JSON.parse(txtDictionary).result
	if debug:
		setUpNewSequence("testDialogue")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	updateText(delta)

func _input(event):
	if event.is_action_pressed("ui_accept") and visible:
		if allTextShown and not $AnimationPlayer.is_playing():
			$AnimationPlayer.play("Hide")
			characterUpdatingAllowed = false
		else:
			visibleCharacters = lbl.get_total_character_count()
		get_tree().set_input_as_handled()


func setUpNewSequence(key):
	if key == "":
		return
	dialogueIndex = -1
	currentTextScene = txtDictionary[key]
	advanceText()

func advanceText():
	dialogueIndex += 1
	if atEndOfDialogue():
		cleanupBox()
		return
	$AudioStreamPlayer.play()
	$AnimationPlayer.play("Show")
	var args = []
	if currentTextScene[dialogueIndex].has("args"):
		args = currentTextScene[dialogueIndex]["args"]
		for i in range(len(args)):
			# Try to grab keybinding argument first
			if InputMap.has_action(args[i]):
				args[i] = InputMap.get_action_list(args[i])[0].as_text()
				continue
			if args[i] in textVariables:	# check if we have a custom variable
				args[i] = textVariables[args[i]]
	lbl.bbcode_text = currentTextScene[dialogueIndex]["dialogue"] % args
	nameLbl.text = currentTextScene[dialogueIndex]["name"]
	updatePortrait()


func updatePortrait():
	var texture
	if "portrait" in currentTextScene[dialogueIndex]:
		texture = currentTextScene[dialogueIndex]["portrait"]
		var path = "res://Player/Dialogue/"+texture+".png"
		$DialogueBoxBackground/MarginContainer/HBoxContainer/Portrait.texture = load(path)


func cleanupBox():
	emit_signal("finished")
	# No need to call hide here, was already called in the previous iteration

func _on_Timer_timeout():
	$AnimationPlayer.play("Hide")

func atEndOfDialogue():
	return dialogueIndex >= len(currentTextScene)

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"Show":
			characterUpdatingAllowed = true
		"Hide":
#			lbl.percent_visible = 0
			lbl.visible_characters = 0
			visibleCharacters = 0.0
			if not atEndOfDialogue():
				advanceText()

func updateText(delta):
	if characterUpdatingAllowed:
		visibleCharacters += delta*charactersToShowPerSecond
		lbl.visible_characters = visibleCharacters
		allTextShown = ( lbl.visible_characters >= lbl.get_total_character_count() )
		if allTextShown:
			$AudioStreamPlayer.stop()


func _on_AudioStreamPlayer_finished():
	var finishedDisplayingText = ( lbl.visible_characters >= lbl.get_total_character_count() )
	if not finishedDisplayingText:
		$AudioStreamPlayer.play()
