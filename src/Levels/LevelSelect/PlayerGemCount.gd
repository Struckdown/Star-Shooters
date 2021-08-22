extends Control




# Called when the node enters the scene tree for the first time.
func _ready():
	UpgradeManager.UIref = self
	updateVisuals()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func updateVisuals():
	$GemCountText.text = "x " + str(UpgradeManager.gems)


func _on_PlayerGemCount_tree_exiting():
	UpgradeManager.UIref = null
