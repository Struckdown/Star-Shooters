extends "res://Hostiles/Waves/WaveBase.gd"


var enemiesRemaining
var finished = false
export(float) var delayAfterCheckpointReadyToAdvance = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func otherAdvanceCondition():
	enemiesRemaining = get_tree().get_nodes_in_group("EnemyBase")
	enemiesRemaining = len(enemiesRemaining)
	updateCheckpointStatus()
 
func OnEnemyDestroyed(_enemy):	# when an enemy is destroyed, it calls a function in a group (this node belongs to that group)
	enemiesRemaining -= 1
	updateCheckpointStatus()

func updateCheckpointStatus():
	if enemiesRemaining <= 0:
		if not finished:
			finished = true
			$Timer.start(delayAfterCheckpointReadyToAdvance)


func _on_Timer_timeout():
	markWaveFinished()
	queue_free()
