extends Node2D


var gems = 0 setget setGems
var UIref = null
var upgrades = {}	# contains "upgradeName": [level, levelMax]. Populated by upgrade items?

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func setGems(_val):
	gems = _val
	if UIref:
		UIref.updateVisuals()
