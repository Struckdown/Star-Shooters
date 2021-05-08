extends Node2D
# Given a game object, follows it until end of lifespawn, and then self-deletes

var GameObjectToFollow
export(PackedScene) var particlesToSpawn
var p

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Must call setup to use
# ParticlesToSpawn is the packed scene, GameObjectToFollow is a gameobject
func init(_particlesToSpawn, _GameObjectToFollow):
	GameObjectToFollow = _GameObjectToFollow
	p = _particlesToSpawn.instance()
	add_child(p)
	p.emitting = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if is_instance_valid(GameObjectToFollow):
		global_position = GameObjectToFollow.global_position
