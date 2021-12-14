extends "res://Hostiles/Waves/WaveBase.gd"

var componentsFinished = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()
	dialogueBoxRef.connect("finished", self, "markDialogueFinished")
	$Node2D/DecisionZone/Area2D/CollisionShape2D.disabled = true
	$Node2D/DecisionZone2/Area2D/CollisionShape2D.disabled = true
	for turret in $finalBossFightShip/Turrets.get_children():
		turret.setActive(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func markDialogueFinished():
	componentsFinished += 1
	if componentsFinished >= 2:
		revealChoices()

func revealChoices():
	$Tween.interpolate_property($Node2D, "modulate", Color(1,1,1,0), Color(1,1,1,1), 3)
	$Tween.start()
	$Node2D/DecisionZone/Area2D/CollisionShape2D.disabled = false
	$Node2D/DecisionZone2/Area2D/CollisionShape2D.disabled = false

func _on_DecisionZone_activated():
	levelManagerRef.addWave(load("res://Levels/Stages/Level10/Dialogue10sidesWithFederation.tscn"))
	levelManagerRef.addWave(load("res://Levels/Stages/Level10/CommanderBoss.tscn"))
	GameManager.endingToPlay = "federationVictory"
	cleanup()

func _on_DecisionZone2_activated():
	levelManagerRef.addWave(load("res://Levels/Stages/Level10/Dialogue10sidesWithCommander.tscn"))
	levelManagerRef.addWave(load("res://Levels/Stages/Level10/FederationBossWave.tscn"))
	GameManager.endingToPlay = "commanderVictory"
	cleanup()

func cleanup():
	$AnimationPlayer.play("cleanup")
	markWaveFinished()


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"default":
			componentsFinished += 1
			if componentsFinished >= 2:
				revealChoices()
		"cleanup":
			queue_free()
