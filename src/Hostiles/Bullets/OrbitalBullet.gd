extends "res://Hostiles/Bullets/Bullet_Base.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()



func init():
	.init()
	if orbitalChildren > 0:
		setChildren(orbitalChildren)
	$RotationRing.rotation = rand_range(0, 2*PI)
	$RotationRing.rotationSpeedDegs = orbitalRotationSpeedDegs

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func setGeneratesEnergy(generates):
	get_node("Sprite").setGeneratesEnergy(generates)


func setChildren(x:int):
	$RotationRing.numOfChildren = x
	$RotationRing.init()

func _on_DespawnTimer_timeout():
	._on_DespawnTimer_timeout()
	for child in $RotationRing/RotatingChildren.get_children():
		if child.has_method("startFadeOut"):
			child.startFadeOut()
		

func checkForWrap():	# orbital bullets never wrap or bounce, it'd be weird.
	pass

func checkForBounce():
	pass
