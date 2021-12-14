extends Node2D
# A simple class that spawns gems every frame until it exhausts, and then deletes itself
export(int) var gemsRemaining = -1
var gemsAllowedToSpawnPerFrame = 5
var gem = load("res://Hostiles/Gem.tscn")
export(bool) var spawnInWaveInsteadOfViewport = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	spawnGems()

func spawnGems():
	for _i in range(gemsAllowedToSpawnPerFrame):
		if gemsRemaining <= 0:
			queue_free()
			break
		var g = gem.instance()
		if spawnInWaveInsteadOfViewport:
			owner.call_deferred("add_child", g)
		else:
			get_viewport().call_deferred("add_child", g)
		g.global_position = self.global_position
		gemsRemaining -= 1
