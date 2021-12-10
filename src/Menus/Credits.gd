extends Control

var netScrollVal = 0
var scrollSpeed = 3

signal closed

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _input(event):
	if event.is_action_pressed("ui_down"):
		netScrollVal += scrollSpeed
	if event.is_action_released("ui_down"):
		netScrollVal -= scrollSpeed
	if event.is_action_pressed("ui_up"):
		netScrollVal -= scrollSpeed
	if event.is_action_released("ui_up"):
		netScrollVal += scrollSpeed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	updateScrolling()

func display(shouldDisplay):
	if shouldDisplay == visible:
		return
	if shouldDisplay:
		visible = true
		$AnimationPlayer.play("Display")
	else:
		$AnimationPlayer.play_backwards("Display")

func updateScrolling():
	$WindowTexture/ScrollContainer.scroll_vertical += netScrollVal

func _on_CloseButton_button_up():
	emit_signal("closed")


func _on_Credits_visibility_changed():
	$WindowTexture/ScrollContainer.scroll_vertical = 0
	if visible:
		$WindowTexture/CloseButton.grab_focus()


func _on_AnimationPlayer_animation_finished(_anim_name):
	pass # Replace with function body.
