extends "res://Hostiles/Waves/WaveBase.gd"

var enemiesToDestroyToAdvanceSegment = [2]
var segmentIndex = 0
var enemiesLeftInSegment = enemiesToDestroyToAdvanceSegment[segmentIndex]

# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()
	enemiesToDestroy = $federationBossFight/Turrets.get_child_count()
	for child in $federationBossFight/Turrets.get_children():
		if child.has_signal("destroyed"):
			child.connect("destroyed", self, "updateEnemyCount")
			enemies.append(child)
	initialAmountOfEnemies = enemiesToDestroy
	advanceToNextSegment()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func advanceToNextSegment():
	enemiesLeftInSegment = enemiesToDestroyToAdvanceSegment[segmentIndex]
	$federationBossFight/Tween.interpolate_property(self, "position", position, Vector2(position.x, position.y+600), 5, Tween.TRANS_SINE)
	$federationBossFight/Tween.start()


func setUpBossHP():	# used by level manager
	var hpTotal = 0
	for child in $federationBossFight/Turrets.get_children():
		if child.has_signal("destroyed"):
			hpTotal += child.maxHealth
			child.setHealthBarRef(bossHPRef)
	if bossHPRef:
		bossHPRef.setup(hpTotal, bossName)

func updateEnemyCount(pointsWorth):
	.updateEnemyCount(pointsWorth)
	enemiesLeftInSegment -= 1
	if enemiesLeftInSegment <= 0:
		advanceToNextSegment()
		segmentIndex += 1
		
