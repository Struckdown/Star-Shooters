extends Node2D

var selectedLevel = null
onready var selectedPlanet
var mapPlayerRef
var nearUpgradePlanet = null
var nearStatsZone = null	# in case we have multiple?

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	GameManager.resetPlayerLives()	# Maybe move lives out of gamemanager into level manager?
	for level in $Levels.get_children():
		level.connect("playerNearby", self, "updateSelectedLevel")
	$CanvasLayer/MissionBriefing.hide()
	BGM.transitionSong("res://Menus/MainMenuBGM.mp3")	# Todo: Find new level select music?
	#GameManager.load_game()
	#get_nodes_in_group()
	mapPlayerRef = get_tree().get_nodes_in_group("Player")[0]
	mapPlayerRef.position = GameManager.mapPlayerLastPos
	mapPlayerRef.rotation = GameManager.mapPlayerLastRot
	calculateTotalScore()
	calculateGameCompletion()

func _exit_tree():
	GameManager.mapPlayerLastPos = mapPlayerRef.position
	GameManager.mapPlayerLastRot = mapPlayerRef.rotation
	GameManager.saveGame()

func _input(event):
	if event.is_action_pressed("fire"):
		if selectedLevel != null and not $CanvasLayer/MissionBriefing.visible:	# check if near level
			#$CanvasLayer/MissionBriefing.show()
			$CanvasLayer/MissionBriefing.playDisplayAnimation("forwards")
			updatePlayerAllowedToMove(false)
			#get_tree().set_input_as_handled()
		if nearUpgradePlanet:
			$CanvasLayer/UpgradeMenu.display(true)
			updatePlayerAllowedToMove(false)
		if nearStatsZone:
			$CanvasLayer/StatsMenu.display(true)
			updatePlayerAllowedToMove(false)
	if Input.is_action_pressed("pause") and not $"CanvasLayer/Pause Menu".visible:
		$"CanvasLayer/Pause Menu".show()
		get_tree().paused = true
		get_tree().get_root().set_input_as_handled()


# Sets the mission briefing data and what will be opened up when the action key is pressed
func updateSelectedLevel(planet):
	if planet == null:
		selectedLevel = null
	else:
		selectedLevel = planet.levelNumber
		$CanvasLayer/MissionBriefing.updateText(planet)


func _on_MissionBriefing_deploy():	# note this also runs at the same time as exit_tree
	if selectedLevel != null:
		GameManager.stage = selectedLevel
		SceneTransition.transitionToScene("res://Levels/Stages/MainWorld.tscn")


func _on_MissionBriefing_cancel():
	updatePlayerAllowedToMove(true)

func save():
	var _save_dict = {
		#TODO
	}

func calculateTotalScore():
	var totalScore = 0
	for p in $Levels.get_children():
		totalScore += int(p.bestScore)
	var prevTotalScore = StatsManager.stats["totalScore"]
	StatsManager.updateStats("totalScore", totalScore-prevTotalScore)

func calculateGameCompletion():
	var levelsComplete = 0
	for p in $Levels.get_children():
		if int(p.bestScore) != 0:
			levelsComplete += 1
	var prevPercentage = StatsManager.stats["gameCompletion"]
	var percentage = float(levelsComplete) / 4.0 * 100
	StatsManager.updateStats("gameCompletion", percentage-prevPercentage)


func _on_UpgradePlanet_playerNearby(ref):
	nearUpgradePlanet = ref


func updatePlayerAllowedToMove(allowed):
	if is_instance_valid(mapPlayerRef):
		mapPlayerRef.canMove = allowed


func _on_UpgradeMenu_shopClosed():
	updatePlayerAllowedToMove(true)


func _on_StatsZone_playerNearby(ref):
	nearStatsZone = ref


func _on_StatsMenu_statsClosed():
	updatePlayerAllowedToMove(true)
