extends Node2D
var playerHitbox = "PlayerOuterHitbox"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# TODO: merge all of these into a single function?

func _on_LeftArea_area_entered(area, isLeft):
	if area.is_in_group(playerHitbox):
		if isLeft:
			area.owner.touchingLeftWall = true
		else:
			area.owner.touchingRightWall = true


func _on_LeftArea_area_exited(area, isLeft):
	if area.is_in_group(playerHitbox):
		if isLeft:
			area.owner.touchingLeftWall = false
		else:
			area.owner.touchingRightWall = false


func _on_BotArea_area_entered(area):
	if area.is_in_group(playerHitbox):
		area.owner.touchingBotWall = true


func _on_BotArea_area_exited(area):
	if area.is_in_group(playerHitbox):
		area.owner.touchingBotWall = false


func _on_TopArea_area_entered(area):
	if area.is_in_group(playerHitbox):
		area.owner.touchingTopWall = true


func _on_TopArea_area_exited(area):
	if area.is_in_group(playerHitbox):
		area.owner.touchingTopWall = false