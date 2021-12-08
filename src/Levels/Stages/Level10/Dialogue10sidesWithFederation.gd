extends "res://Hostiles/Waves/WaveBase.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()
	levelManagerRef.playerSpawn.useAlternativeSkin = true
	levelManagerRef.spawnNewPlayer(0)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

