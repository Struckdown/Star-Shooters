extends Control


var backgrounds = [
	"res://Space Shooter Redux/Backgrounds/black.png",
	"res://Space Shooter Redux/Backgrounds/blue.png",
	"res://Space Shooter Redux/Backgrounds/darkPurple.png",
	"res://Space Shooter Redux/Backgrounds/purple.png"
]


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	var i = randi() % (backgrounds.size()-1)
	var bg = backgrounds[i]
	$BG.texture = load(bg)
	$"/root/SceneTransition".connect("fadeFinished", self, "fadeFinished")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_PlayBtn_button_down():
	$"/root/SceneTransition".fadetoBlack()

func fadeFinished():
	get_tree().change_scene("res://World.tscn")
