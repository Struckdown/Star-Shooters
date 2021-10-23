extends Control

onready var lbl = $DialogueBoxBackground/MarginContainer/HBoxContainer/VBoxContainer/RichText
onready var nameLbl = $DialogueBoxBackground/MarginContainer/HBoxContainer/VBoxContainer/NameLbl
var filePath = "res://Player/Dialogue/dialogue.json"
var txtDictionary
var dialogueIndex = 0
var currentTextScene = []

signal finished

# Called when the node enters the scene tree for the first time.
func _ready():
	var file = File.new()
	file.open(filePath, File.READ)
	txtDictionary = file.get_as_text()
	var err = JSON.parse(txtDictionary)
	if err.result == null:
		print(err)
	txtDictionary = JSON.parse(txtDictionary).result


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if event.is_action_pressed("ui_accept") and visible:
		$AnimationPlayer.play("Hide")
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
	$AnimationPlayer.play("Show")
	lbl.bbcode_text = currentTextScene[dialogueIndex]["dialogue"]
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
			pass
		"Hide":
			lbl.percent_visible = 0
			if not atEndOfDialogue():
				advanceText()
