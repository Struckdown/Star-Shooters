extends Control


onready var fakePlayer = $Window/ViewportContainer/Viewport/Player
var fakeEnergy = 0
var maxEnergy = 0
var tutorialFinished = false


# Called when the node enters the scene tree for the first time.
func _ready():
	$Window/ViewportContainer/Viewport/ScoreboardPnl.updateCharge(fakeEnergy)

func _unhandled_input(_event):
	if tutorialFinished:
		queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Player_energyUpdated():
	fakeEnergy = fakePlayer.energyLevel / 10000.0
	if maxEnergy != 0:
		fakeEnergy -= maxEnergy/4
	$Window/ViewportContainer/Viewport/ScoreboardPnl.updateCharge(fakeEnergy)

func updateMaxEnergy():
	maxEnergy = fakeEnergy

func resetEnergy():
	fakeEnergy = 0
	fakePlayer.energyLevel = 0
	$Window/ViewportContainer/Viewport/ScoreboardPnl.updateCharge(fakeEnergy)


func _on_AnimationPlayer_animation_finished(anim_name):
	tutorialFinished = true
	$AnimationPlayer.play("Demo")
	$TextAnimationPlayer.play("Blink")
