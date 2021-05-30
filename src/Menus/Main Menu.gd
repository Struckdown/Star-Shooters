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
	$CanvasLayer/Settings.connect("closed", self, "hideSettings")
	GameManager.resetGame()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Menu_button_up(btn):
	match btn:
		"play":
			if $VBoxContainer/PlayBtn.is_hovered():
				GameManager.stage = "Main"
				$"/root/SceneTransition".transitionToScene("res://Levels/Stages/MainWorld.tscn")
		"infinite":
			if $VBoxContainer/InfiniteBtn.is_hovered():
				GameManager.stage = "Infinite"
				$"/root/SceneTransition".transitionToScene("res://Levels/Stages/MainWorld.tscn")
		"tutorial":
			if $VBoxContainer/TutorialBtn.is_hovered():
				GameManager.stage = "Tutorial"
				$"/root/SceneTransition".transitionToScene("res://Levels/Stages/MainWorld.tscn")
		"options":
			$CanvasLayer/Settings.show()
		"exit":
			if $VBoxContainer/ExitBtn.is_hovered():
				get_tree().quit()
		_:
			pass

func hideSettings():
	$CanvasLayer/Settings.hide()
