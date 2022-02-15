extends "res://Hostiles/Enemies/Enemy_Base.gd"

# Carrier boss

var spawnedMinions = []
var maxMinions = 4
var preloadedMinion = preload("res://Hostiles/Enemies/BossL3Minion.tscn")
var hangerIndex = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func spawnMinion():
	var minion = preloadedMinion.instance()
	spawnedMinions.append(minion)
	get_parent().get_parent().add_child(minion)
	minion.connect("wantsNewTarget", self, "assignNewMinionTarget", [minion])
	minion.connect("destroyed", self, "onMinionDied", [minion])
	var hanger = get_node("Sprite/cockpitBlue_" + str(hangerIndex+1))
	minion.global_position = hanger.global_position
	minion.global_rotation = hanger.global_rotation
	hangerIndex = (hangerIndex+1)%2

func onMinionDied(_pointsWorth, minion):
	var i = 0
	for m in spawnedMinions:
		if m == minion:
			spawnedMinions.remove(i)
			break
		i += 1

func _on_MinionSpawnTimer_timeout():
	if len(spawnedMinions) < maxMinions:
		spawnMinion()

func assignNewMinionTarget(minion):
	if not is_instance_valid(minion.target):
		minion.target = self
		return
	if minion.target == self:
		if getPlayer() == null:
			minion.target = self
		else:
			minion.target = getPlayer()
	elif minion.target == getPlayer():
		minion.target = self

func getPlayer():
	var players = get_tree().get_nodes_in_group("Player")
	var p = null
	if len(players) > 0:
		p = players[0]
	return p

func _exit_tree():
	for m in spawnedMinions:
		if is_instance_valid(m):
			m.destroy()
