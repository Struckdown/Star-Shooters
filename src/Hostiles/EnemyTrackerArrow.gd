extends Node2D

var freeRequested = false

# Given an enemy, follows it every frame
# When the enemy dies, this arrow also dequeues
var enemyToFollow

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("FadeIn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if is_instance_valid(enemyToFollow):
		global_position.x = enemyToFollow.global_position.x

func OnEnemyDestroyed(destroyedEnemy):
	if destroyedEnemy == enemyToFollow:
		freeRequested = true
		$AnimationPlayer.play_backwards("FadeIn")


func _on_AnimationPlayer_animation_finished(_anim_name):
	if freeRequested:
		queue_free()
