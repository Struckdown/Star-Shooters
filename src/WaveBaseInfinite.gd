extends "res://Hostiles/Waves/WaveBase.gd"

var percentageToUsePathOverHover = 30
var percentageToUseInfinitePaths = 90
var enemiesToSpawn = 0
var baseEnemy = preload("res://Hostiles/Enemies/Enemy_Base.tscn")
var enemyPointDistributions = {
	1:[
		[100]
	],
	2:[
		[80, 20],
		[50, 50],
	],
	3:[
		[80, 10, 10],
		[50, 30, 20],
		[34, 33, 33],
	],
	4:[
		[85, 5, 5, 5],
		[50, 30, 10, 10],
		[40, 30, 20, 10],
		[25, 25, 25, 25],
	],
	5:[
		[80, 5, 5, 5, 5],
		[60, 25, 5, 5, 5],
		[60, 10, 10, 10, 10],
		[50, 20, 10, 10, 10],
		[20, 20, 20, 20, 20]
	]
}
const MAX_ENEMIES_IN_SINGLE_WAVE = 5
var enemiesAllLeaveOnPath = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass	# overwrites ready. We use allocateDifficultyPoints instead as the init


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func allocateDifficultyPoints(pointsToSpend:int):
	enemiesAllLeaveOnPath = true
	var upperLimit = min(int(pointsToSpend/25.0), MAX_ENEMIES_IN_SINGLE_WAVE)
	upperLimit = max(1, upperLimit)	# force this to always be at least 1
	enemiesToSpawn = rand_range(1, upperLimit)
	
	var distributions = enemyPointDistributions[int(enemiesToSpawn)]
	var dist = rand_range(0, len(distributions))
	dist = distributions[dist]	# dist is now an array of weights
	enemiesToDestroy = enemiesToSpawn
	for i in range(enemiesToSpawn):
		var enemyWeight = dist[i]	# assign a weight, eg [40, 30, 30] would assign 40% of points to first enemy
		var e = baseEnemy.instance()
		add_child(e)
		setupStartPositionAndPath(e)
		e.setupWithPoints(enemyWeight*0.01*pointsToSpend)
		# decide on what fly pattern to use
		# decide on what shot types to use
		# decide if enemies advance on time or destroyed (correlate with fly pattern)
	enemiesAllLeaveOnPath = false
	if enemiesAllLeaveOnPath:
		waveAdvanceCondition = "time"
	else:
		waveAdvanceCondition = "enemies"
	._ready()

func setupStartPositionAndPath(enemy):
	enemy.position = $Position2D.position
	enemy.rotation = $Position2D.rotation
	enemy.flyingPattern = "hoverRandomPoint"
	enemy._ready()
	# if any enemy is set to hover or loop path, set enemiesAllLeaveOnPath to false
	#	enemiesAllLeaveOnPath = false
	