extends Node2D


var gems = 200055 setget setGems
var UIref = null
var upgrades = {}	# contains "upgradeName": {"curLevel":0, "upgradeLevels":[0, 10, 20, 30, 40, 50], "startingCost": 100, }. Populated by upgrade items
# Upgrades so far: respawn energy, energy cap, energy gain, magnet radius

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
