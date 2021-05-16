extends Node2D
var playerHitbox = "PlayerOuterHitbox"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# TODO: merge all of these into a single function? Bit masks would work well here probably. Consider as a TODO refactor that probably never gets done
# I do admit this is gross and poor practice.

func _on_LeftArea_area_entered(area, isLeft):
	if area.is_in_group(playerHitbox) and is_instance_valid(area.owner):
		if isLeft:
			area.owner.touchingLeftWall = true
		else:
			area.owner.touchingRightWall = true


func _on_LeftArea_area_exited(area, isLeft):
	if area.is_in_group(playerHitbox) and is_instance_valid(area.owner):
		if isLeft:
			area.owner.touchingLeftWall = false
		else:
			area.owner.touchingRightWall = false


func _on_BotArea_area_entered(area):
	if area.is_in_group(playerHitbox) and is_instance_valid(area.owner):
		area.owner.touchingBotWall = true


func _on_BotArea_area_exited(area):
	if area.is_in_group(playerHitbox) and is_instance_valid(area.owner):
		area.owner.touchingBotWall = false


func _on_TopArea_area_entered(area):
	if area.is_in_group(playerHitbox) and is_instance_valid(area.owner):
		area.owner.touchingTopWall = true


func _on_TopArea_area_exited(area):
	if area.is_in_group(playerHitbox) and is_instance_valid(area.owner):
		area.owner.touchingTopWall = false


func _on_GemZone_area_entered(area):
	if area.owner.is_in_group("Player"):
		if not $AudioStreamPlayer.playing:
			$AudioStreamPlayer.play()
		for gem in get_tree().get_nodes_in_group("Gem"):
			if gem.owner:
				gem.owner.playerRef = area.owner

