extends Node2D

export(GameManager.playerFireTypes) var playerFireTypeUnlock = GameManager.playerFireTypes.SPREAD
signal collected

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area2D_area_entered(area):
	if area.is_in_group("PlayerOuterHitbox"):
		GameManager.unlockFireMode(playerFireTypeUnlock)
		emit_signal("collected")
		queue_free()

func setUpgrade(upgradeType):
	playerFireTypeUnlock = upgradeType
	var resourcePath = ""
	match upgradeType:
		GameManager.playerFireTypes.CHARGE:
			resourcePath = "res://Space Shooter Redux/PNG/Power-ups/powerupRed_bolt.png"
		GameManager.playerFireTypes.FOCUSED:
			resourcePath = "res://Space Shooter Redux/PNG/Power-ups/powerupBlue_bolt.png"
		GameManager.playerFireTypes.REVERSE:
			resourcePath = "res://Space Shooter Redux/PNG/Power-ups/powerupYellow_bolt.png"
		GameManager.playerFireTypes.SPREAD:
			resourcePath = "res://Space Shooter Redux/PNG/Power-ups/powerupGreen_bolt.png"
	$Sprite.texture = load(resourcePath)
