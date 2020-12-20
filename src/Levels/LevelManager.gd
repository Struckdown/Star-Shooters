extends Node2D


onready var scoreBoardRef
onready var playerRef

# Called when the node enters the scene tree for the first time.
func _ready():
	scoreBoardRef = get_node("Scoreboard")
	playerRef = get_node("Player")
	playerRef.connect("energyUpdated", self, "updateCharge")
	updateCharge()
	$"/root/SceneTransition".fadeinFromBlack()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if Input.is_action_pressed("pause"):
		$"CanvasLayer/Pause Menu".show()
		get_tree().paused = true

func updateCharge():
	scoreBoardRef.updateCharge(playerRef.energyLevel / playerRef.energyLimit)
