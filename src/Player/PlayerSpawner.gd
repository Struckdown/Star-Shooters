extends Node2D


export(PackedScene) var playerToSpawn
var playerRef
var useAlternativeSkin = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func spawnPlayer():
	if playerRef != null:
		playerRef.queue_free()
	playerRef = playerToSpawn.instance()
	if useAlternativeSkin:
		playerRef.applyAlternativeSkin()
	get_parent().add_child(playerRef)
	playerRef.global_position = global_position
	playerRef.spawn()
	$AudioStreamPlayer.play()
	return playerRef

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
