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
	BGM.transitionSong("res://Menus/MainMenuBGM.mp3")
	get_node("VBoxContainer/PlayBtn").grab_focus()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Menu_button_up(btn):
	match btn:
		"play":
			if $VBoxContainer/PlayBtn.is_hovered():
				GameManager.gameMode = "Main"
				$ButtonClickedSFX.play()
				$"/root/SceneTransition".transitionToScene("res://Levels/LevelSelect/LevelSelect.tscn")
				
		"infinite":
			if $VBoxContainer/InfiniteBtn.is_hovered():
				GameManager.gameMode = "Infinite"
				$ButtonClickedSFX.play()
				$"/root/SceneTransition".transitionToScene("res://Levels/LevelSelect/LevelSelect.tscn")
		"tutorial":
			if $VBoxContainer/TutorialBtn.is_hovered():
				GameManager.gameMode = "Tutorial"
				$ButtonClickedSFX.play()
				$"/root/SceneTransition".transitionToScene("res://Levels/LevelSelect/LevelSelect.tscn")
		"options":
			$ButtonClickedSFX.play()
			$CanvasLayer/Settings.show()
		"exit":
			if $VBoxContainer/ExitBtn.is_hovered():
				$ButtonClickedSFX.play()
				get_tree().quit()
		_:
			pass

func hideSettings():
	$CanvasLayer/Settings.hide()
	get_node("VBoxContainer/OptionsBtn").grab_focus()


func _on_Btn_mouse_entered():
	$ButtonHoveredSFX.play()
