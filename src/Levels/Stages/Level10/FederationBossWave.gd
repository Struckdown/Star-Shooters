extends "res://Hostiles/Waves/WaveBase.gd"

var enemiesToDestroyToAdvanceSegment = [2, 3, 3, 1, 2, 2, 1, 1]
var segmentIndex = -1
var enemiesLeftInSegment = enemiesToDestroyToAdvanceSegment[segmentIndex]
var initPosition

# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()
	initPosition = $federationBossFight.position
	enemiesToDestroy = $federationBossFight/Turrets.get_child_count()
	for child in $federationBossFight/Turrets.get_children():
		if child.has_signal("destroyed"):
			child.connect("destroyed", self, "updateEnemyCount")
			enemies.append(child)
			child.setActive(false)
	initialAmountOfEnemies = enemiesToDestroy
	advanceToNextSegment()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if event.is_action_pressed("switchWeapons"):
		pass
		print(name, " debug used to advance segment")
		advanceToNextSegment()

func advanceToNextSegment():
	if segmentIndex >= 0:
		$ExplosionBoxParticles.emitting = true
		$ExplosionBoxParticles/TurnOffTimer.start()
	segmentIndex += 1
	var pos = $federationBossFight.position
	if segmentIndex < len(enemiesToDestroyToAdvanceSegment):
		enemiesLeftInSegment = enemiesToDestroyToAdvanceSegment[segmentIndex]
		var targetY = initPosition.y+(600*(segmentIndex+1))
		if segmentIndex == 7:
			targetY = targetY - 300
		$federationBossFight/Tween.interpolate_property($federationBossFight, "position", pos, Vector2(pos.x, targetY), 5, Tween.TRANS_SINE)
		$federationBossFight/Tween.start()
		$ActivateTurretsTimer.start()
	else:
		$federationBossFight/Tween.interpolate_property($federationBossFight, "position", pos, Vector2(pos.x, pos.y+1500), 3, Tween.TRANS_SINE)
		$federationBossFight/Tween.start()
		yield(get_tree().create_timer(3), "timeout")
		markWaveFinished()


func setUpBossHP():	# used by level manager
	var hpTotal = 0
	for child in $federationBossFight/Turrets.get_children():
		if child.has_signal("destroyed"):
			hpTotal += child.maxHealth
			child.setHealthBarRef(bossHPRef)
	hpTotal += $federationBossFight/FederationEye.maxHealth	# add core's health to total
	if bossHPRef:
		bossHPRef.setup(hpTotal, bossName)

func updateEnemyCount(pointsWorth):
	.updateEnemyCount(pointsWorth)
	enemiesLeftInSegment -= 1
	if enemiesLeftInSegment <= 0:
		advanceToNextSegment()

func getEnemies():
	var e = []
	for child in $federationBossFight/Turrets.get_children():
		if child.is_in_group("EnemyBase"):
			e.append(child)
	return e


func _on_TurnOffTimer_timeout():
	$ExplosionBoxParticles.emitting = false


func _on_ActivateTurretsTimer_timeout():
	var i = enemiesLeftInSegment
	for e in getEnemies():
		e.setActive(true)
		if arrowTrackerRef:
			arrowTrackerRef.startTrackingNewEnemy(e)
		i -= 1
		if i <= 0:
			break


# Function overwritten to do nothing in this wave, we do it with the timer
func startArrowTracking():
	pass
