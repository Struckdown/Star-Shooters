extends Control


var backgrounds = [
	"res://Space Shooter Redux/Backgrounds/black.png",
	"res://Space Shooter Redux/Backgrounds/blue.png",
	"res://Space Shooter Redux/Backgrounds/darkPurple.png",
	"res://Space Shooter Redux/Backgrounds/purple.png"
]


# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.resetPlayerLives()
	randomize()
	var i = randi() % (backgrounds.size()-1)
	var bg = backgrounds[i]
	$BG.texture = load(bg)
	if $CanvasLayer/Settings.connect("closed", self, "hideSettings"):
		print("CanvasLayer/Settings connect failed???")
	BGM.transitionSong("res://Menus/MainMenuBGM.mp3")
	get_node("MainBtns/PlayBtn").grab_focus()
	setupExtraInfolbl()
	setupMissionsCompleted()

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
				GameManager.setGameMode(GameManager.gamesModes.STORY)
				$ButtonClickedSFX.play()
				$"/root/SceneTransition".transitionToScene("res://Levels/LevelSelect/LevelSelect.tscn")
		"back":
				$MainBtns.show()
				$PlayBtns.hide()
				$ExtraBtns.hide()
				$MainBtns/PlayBtn.grab_focus()
		"new game":
			if $PlayBtns/NewGameBtn.is_hovered():
				GameManager.setGameMode(GameManager.gamesModes.STORY)
				$ButtonClickedSFX.play()
				UpgradeManager.clearSaveData()
				StatsManager.clearSaveData()
				GameManager.clearSaveData()
				GameManager.saveGame()
				$"/root/SceneTransition".transitionToScene("res://Levels/LevelSelect/LevelSelect.tscn")
		"infinite":
			if $ExtraBtns/InfiniteBtn.is_hovered():
				GameManager.setGameMode(GameManager.gamesModes.INFINITE)
				GameManager.stage = "Infinite"
				$ButtonClickedSFX.play()
				$"/root/SceneTransition".transitionToScene("res://Levels/Stages/MainWorld.tscn")
		"tutorial":
			if $MainBtns/TutorialBtn.is_hovered():
				GameManager.setGameMode(GameManager.gamesModes.TUTORIAL)
				GameManager.stage = "0"
				$ButtonClickedSFX.play()
				$"/root/SceneTransition".transitionToScene("res://Levels/Stages/MainWorld.tscn")
		"extras":
			$ButtonClickedSFX.play()
			$ExtraBtns.show()
			$MainBtns.hide()
			$ExtraBtns/BossRushBtn.grab_focus()
		"options":
			$ButtonClickedSFX.play()
			$CanvasLayer/Settings.show()
		"credits":
			if $MainBtns/CreditsBtn.is_hovered():
				$ButtonClickedSFX.play()
				$CanvasLayer/Credits.display(true)
		"exit":
			if $MainBtns/ExitBtn.is_hovered():
				$ButtonClickedSFX.play()
				SceneTransition.fadetoBlack()
				yield(SceneTransition, "fadeFinished")
				get_tree().quit()
		"BossRush":
			if $ExtraBtns/BossRushBtn.is_hovered():
				GameManager.setGameMode(GameManager.gamesModes.BOSSRUSH)
				GameManager.stage = "BossRush"
				$ButtonClickedSFX.play()
				$"/root/SceneTransition".transitionToScene("res://Levels/Stages/MainWorld.tscn")
		_:
			pass

func hideSettings():
	$CanvasLayer/Settings.hide()
	get_node("MainBtns/OptionsBtn").grab_focus()


func _on_Btn_mouse_entered():
	$ButtonHoveredSFX.play()


func _on_Credits_closed():
	$CanvasLayer/Credits.display(false)
	$MainBtns/CreditsBtn.grab_focus()

func resetMainMenuBullet():
	$AnimationPlayer/Bullet_Straight/Area2D.add_to_group("generatesEnergy")

func setupExtraInfolbl():
	var bossRushScore = 0
	var infiniteScore = 0
	if "BossRush" in GameManager.stagesCompletedData:
		bossRushScore = GameManager.stagesCompletedData["BossRush"]
	var finalString = "Boss Rush Score: " + str(bossRushScore) + "\n"
	if "Infinite" in GameManager.stagesCompletedData:
		infiniteScore = GameManager.stagesCompletedData["Infinite"]
	finalString += "Infinite Mode Score: " + str(infiniteScore) 
	$ExtraBtns/ExtraInfoLbl.text = finalString

func setupMissionsCompleted():
	var missionsCompleted = len(GameManager.stagesCompletedData)
	for mission in ["BossRush", "0", "InfiniteMode"]:
		if mission in GameManager.stagesCompletedData:
			missionsCompleted -= 1
	$PlayBtns/MissionsCompletedLbl.text = "Missions Completed: " + str(missionsCompleted)
