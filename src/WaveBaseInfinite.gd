extends "res://Hostiles/Waves/WaveBase.gd"

var percentageToUsePathOverHover = 0.3
var percentageToUseInfinitePaths = 0.9
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
	var upperLimit = min(int(pointsToSpend/10.0), MAX_ENEMIES_IN_SINGLE_WAVE)
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
		e.setupWithPoints(enemyWeight*0.01*pointsToSpend)
		setupStartPositionAndPath(e)
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
	var positionNode
	var i = randf()
	if i <= percentageToUsePathOverHover:
		# using a path, now pick which group of paths
		i = randf()
		var pathGroup
		if i <= percentageToUseInfinitePaths:
			pathGroup = $LoopPaths
			enemy.loopFlyPaths = true
		else:
			pathGroup = $FinitePaths
			enemy.loopFlyPaths = false
		var childrenCount = pathGroup.get_child_count()
		var path = pathGroup.get_child(rand_range(0, childrenCount-1))
		positionNode = path.get_child(0)
		enemy.flyingPattern = "followPath"
		enemy.flyPaths = [NodePath(path.get_path())]
		
	else:
		i = $DefaultSpawnPoints.get_child_count()
		positionNode = $DefaultSpawnPoints.get_child(randi()%i)
		enemy.flyingPattern = "hoverRandomPoint"
		enemy.maxRotationSpeed *= 10
		enemy.useAcclerationInsteadOfLinearVelocity = bool(randi()%2)
		if enemy.useAcclerationInsteadOfLinearVelocity:
			enemy.speed /= 100.0
	enemy.position = positionNode.position
	enemy.rotation = positionNode.rotation
	enemy._ready()
	# if any enemy is set to hover or loop path, set enemiesAllLeaveOnPath to false
	#	enemiesAllLeaveOnPath = false
	
