extends Control


var backgrounds = [
	"res://Space Shooter Redux/Backgrounds/black.png",
	"res://Space Shooter Redux/Backgrounds/blue.png",
	"res://Space Shooter Redux/Backgrounds/darkPurple.png",
	"res://Space Shooter Redux/Backgrounds/purple.png"
]


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	var i = randi() % (backgrounds.size()-1)
	var bg = backgrounds[i]
	$BG.texture = load(bg)
	if $"/root/SceneTransition".connect("fadeFinished", self, "fadeFinished"):
		print("Connect failed with fade?")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func fadeFinished():
	if get_tree().change_scene("res://World.tscn"):
		print("Scene failed to transition")


func _on_ExitBtn_button_up():
	if $VBoxContainer/ExitBtn.is_hovered():
		get_tree().quit()

func _on_PlayBtn_button_up():
	if $VBoxContainer/MarginContainer/PlayBtn.is_hovered():
		$"/root/SceneTransition".fadetoBlack()
