extends "res://Hostiles/Waves/WaveBase.gd"

var levelManagerRef

# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()
	levelManagerRef = get_tree().get_nodes_in_group("LevelManager")
	if len(levelManagerRef) > 0:
		levelManagerRef = levelManagerRef[0]
	dialogueBoxRef.connect("finished", self, "revealChoices")
	$Node2D/DecisionZone/Area2D/CollisionShape2D.disabled = true
	$Node2D/DecisionZone2/Area2D/CollisionShape2D.disabled = true
	for turret in $finalBossFightShip/Turrets.get_children():
		turret.setActive(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func revealChoices():
	$Tween.interpolate_property($Node2D, "modulate", Color(1,1,1,0), Color(1,1,1,1), 3)
	$Tween.start()
	$Node2D/DecisionZone/Area2D/CollisionShape2D.disabled = false
	$Node2D/DecisionZone2/Area2D/CollisionShape2D.disabled = false

func _on_DecisionZone_activated():
	#levelManagerRef.addWave(load("res://Levels/Stages/Level10/CommanderBoss.tscn"))
	levelManagerRef.addWave(load("res://Levels/Stages/Level10/CommanderBoss.tscn"))
	cleanup()

func _on_DecisionZone2_activated():
	levelManagerRef.addWave(load("res://Levels/Stages/Level10/Dialogue10sidesWithCommander.tscn"))
	levelManagerRef.addWave(load("res://Levels/Stages/Level10/FederationBossWave.tscn"))
	cleanup()

func cleanup():
	$AnimationPlayer.play("cleanup")
	markWaveFinished()
