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
	if $CanvasLayer/Settings.connect("closed", self, "hideSettings"):
		print("CanvasLayer/Settings connect failed???")
	GameManager.resetGame()
	BGM.transitionSong("res://Menus/MainMenuBGM.mp3")
	get_node("MainBtns/PlayBtn").grab_focus()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Menu_button_up(btn):
	match btn:
		"play":
			if $MainBtns/PlayBtn.is_hovered():
				$MainBtns.hide()
				$PlayBtns.show()
				$PlayBtns/ContinueBtn.grab_focus()
		"continue":
			if $PlayBtns/ContinueBtn.is_hovered():
				GameManager.gameMode = "Main"
				$ButtonClickedSFX.play()
				$"/root/SceneTransition".transitionToScene("res://Levels/LevelSelect/LevelSelect.tscn")
		"back":
			if $PlayBtns/BackBtn.is_hovered():
					$MainBtns.show()
					$PlayBtns.hide()
					$MainBtns/PlayBtn.grab_focus()
		"new game":
			if $PlayBtns/NewGameBtn.is_hovered():
				GameManager.gameMode = "Main"
				$ButtonClickedSFX.play()
				UpgradeManager.clearSaveData()
				$"/root/SceneTransition".transitionToScene("res://Levels/LevelSelect/LevelSelect.tscn")
		"infinite":
			if $MainBtns/InfiniteBtn.is_hovered():
				GameManager.gameMode = "Infinite"
				$ButtonClickedSFX.play()
				$"/root/SceneTransition".transitionToScene("res://Levels/LevelSelect/LevelSelect.tscn")
		"tutorial":
			if $MainBtns/TutorialBtn.is_hovered():
				GameManager.gameMode = "Tutorial"
				GameManager.stage = 0
				$ButtonClickedSFX.play()
				$"/root/SceneTransition".transitionToScene("res://Levels/Stages/MainWorld.tscn")
		"options":
			$ButtonClickedSFX.play()
			$CanvasLayer/Settings.show()
		"exit":
			if $MainBtns/ExitBtn.is_hovered():
				$ButtonClickedSFX.play()
				get_tree().quit()
		_:
			pass

func hideSettings():
	$CanvasLayer/Settings.hide()
	get_node("VBoxContainer/OptionsBtn").grab_focus()


func _on_Btn_mouse_entered():
	$ButtonHoveredSFX.play()
