extends Node2D

export(String, MULTILINE) var levelDescription # Sector Name
var bestScore = 0
export(String) var levelName
signal playerNearby
export(String, MULTILINE) var missionName
export(String, MULTILINE) var missionBriefing
var planetRotationSpeed = 0
export(bool) var unlocked = false
export(Array, NodePath) var levelsToUnlock = []

func _ready():
	set_description()
	setupPlanetSpeed()
	if unlocked:
		unlockLevel()

func setupPlanetSpeed():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	# random speed and then multiply by -1 or 1 randomly
	planetRotationSpeed = rand_range(0.5, 1) * (rng.randi_range(0,1)*2-1)

func _unhandled_input(event):
	if GameManager.debugMode and event is InputEventKey and event.is_pressed():
		if event.scancode == KEY_U:
			#print("Player: Cheat mode not allowed!")
			unlockLevel()
			print("SelectablePlanet: Cheat mode activated, all levels unlocked")

func _process(delta):
	updateIdleAnimation(delta)

func updateIdleAnimation(delta) -> void:
	$PlanetSprite.rotation_degrees += delta*planetRotationSpeed*5


func set_description() -> void:
	$LevelPanel/LevelDescription.text = levelDescription + "\n" + missionName
	if levelName in GameManager.stagesCompletedData:
		bestScore = GameManager.stagesCompletedData[levelName]
	$LevelPanel/BestScoreLbl.text = "Best Score: " + str(bestScore)


func _on_Area2D_area_entered(area):
	if not unlocked:
		return
	if area.owner.is_in_group("Player"):
		emit_signal("playerNearby", self)


func _on_Area2D_area_exited(area):
	if area.owner.is_in_group("Player"):
		emit_signal("playerNearby", null)


func _on_DisplayArea2D_area_entered(area):
	if area.owner.is_in_group("Player"):
		$AnimationPlayer.play("DisplayLevelInfo")



func _on_DisplayArea2D_area_exited(area):
	if area.owner.is_in_group("Player"):
		$AnimationPlayer.play_backwards("DisplayLevelInfo")

func unlockLevel():
	$Lock.hide()
	unlocked = true
	if levelName in GameManager.stagesCompletedData:
		for level in levelsToUnlock:
			var otherLevel = get_node(level)
			if not otherLevel.unlocked:	# avoids circular loops
				otherLevel.unlockLevel()
