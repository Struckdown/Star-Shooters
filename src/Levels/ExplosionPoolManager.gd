extends Node2D

export(int) var maxSingleExplosionsAllowed = 100
export(int) var maxExplosionsAllowed = 5
var playerBulletExplosion = preload("res://Explosions/SingleExplosion.tscn")
var multiExplosion = preload("res://Explosions/MultiExplosion.tscn")
var followingParticles = preload("res://Utility/FollowingParticles.tscn")
var indicies = [0, 0]	# single, multi

# Called when the node enters the scene tree for the first time.
func _ready():
	for _i in range(maxSingleExplosionsAllowed):
		var e = playerBulletExplosion.instance()
		$SingleExplosions.add_child(e)
		e.position = Vector2(-100, 100)
		e.get_node("Timer").stop()
		e.get_node("AudioStreamPlayer").playing = false
	for _i in range(maxExplosionsAllowed):
		var e = followingParticles.instance()
		$MultiExplosions.add_child(e)
		e.position = Vector2(-100, 100)
		e.init(multiExplosion, null, false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func requestExplosion(type, pos, objectToFollow=null):
	match type:
		"single":
			var b = $SingleExplosions.get_child(indicies[0])
			b.position = pos
			b.play()
			indicies[0] = (indicies[0] + 1) % maxSingleExplosionsAllowed
		"multi":
			var b = $MultiExplosions.get_child(indicies[1])
			b.startEmitting()
			indicies[1] = (indicies[1] + 1) % maxExplosionsAllowed
			if objectToFollow:
				b.GameObjectToFollow = objectToFollow
