extends "res://Hostiles/Waves/WaveBase.gd"

export(GameManager.playerFireTypes) var upgradeToSpawn = GameManager.playerFireTypes.SPREAD
var upgrade = load("res://Player/Upgrades/Upgrade.tscn")



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func otherAdvanceCondition():
	pass


func _on_Area2D_area_entered(area):
	if area.is_in_group("Enemy"):
		var u = upgrade.instance()
		u.global_position = area.global_position
		u.setUpgrade(upgradeToSpawn)
		get_viewport().call_deferred("add_child", u)
		u.connect("collected", self, "markWaveFinished")
		$Area2D.queue_free()
