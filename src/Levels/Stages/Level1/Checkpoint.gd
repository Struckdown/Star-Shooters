extends "res://Hostiles/Waves/WaveBase.gd"


var enemiesRemaining

# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func otherAdvanceCondition():
	enemiesRemaining = get_tree().get_nodes_in_group("EnemyBase")
	enemiesRemaining = len(enemiesRemaining)
	if enemiesRemaining <= 0:
		markWaveFinished()
		queue_free()
	
 
func OnEnemyDestroyed():	# when an enemy is destroyed, it calls a function in a group (this node belongs to that group)
	enemiesRemaining -= 1
	if enemiesRemaining <= 0:
		markWaveFinished()
		queue_free()


