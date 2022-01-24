extends Node2D

var shieldBotToLoad = preload("res://Hostiles/Enemies/Shield_Bot.tscn")
var shieldBotRef = null
var targetRef	# should be the thing to protect

signal shieldBotDestroyed

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func startSpawningBot():
	if is_instance_valid(shieldBotRef):
		return
	$Tween.interpolate_property(self, "scale", scale, Vector2(-scale.x, scale.y), 1)
	$Tween.start()
	$AnimationPlayer.play("Spawn")

func spawnBot():
	shieldBotRef = shieldBotToLoad.instance()
	shieldBotRef.scale = Vector2(1.25, 1.25)
	add_child(shieldBotRef)
	yield(get_tree().create_timer(0.06), "timeout")
	shieldBotRef.assignTarget(targetRef)
	shieldBotRef.connect("destroyedWithoutWaveProgression", self, "markShieldBotDestroyed")

func markShieldBotDestroyed():
	emit_signal("shieldBotDestroyed")
