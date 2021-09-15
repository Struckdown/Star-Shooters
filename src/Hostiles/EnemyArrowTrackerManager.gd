extends Node2D
# Manages Arrows that follow enemies
var arrowTypeToInstance = load("res://Hostiles/EnemyTrackerArrow.tscn")
# Called when the node enters the scene tree for the first time.

func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func startTrackingNewEnemy(enemy):
	var arrow = arrowTypeToInstance.instance()
	add_child(arrow)
	arrow.enemyToFollow = enemy
	var vpr = get_viewport_rect()	# returns Rect2
	arrow.position.y = vpr.position[1] + vpr.size[1]	# grab y and height to create position
