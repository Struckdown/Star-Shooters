extends "res://Hostiles/Bullets/Bullet_Base.gd"

var prevMoveDir = Vector2.ZERO
var moveDir = Vector2.ZERO
var hasPassedTarget = false

# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()
	updateDirection()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	updateDirection()
	move(delta)
	updateNodeToRotate(delta)

func move(delta):
	position += moveDir * delta * moveSpeed

func updateDirection():
	if hasPassedTarget:
		return
	if not is_instance_valid(target):
		moveDir = Vector2(0, 1)
		return
	var positionDifference = (target.position - position)
	var axisDelta
	if trackYFirst:
		axisDelta = positionDifference.y
	else:
		axisDelta = positionDifference.x
	if axisDelta == 0:	# avoid division by zero in following statement
		axisDelta = 1
	axisDelta /= abs(axisDelta)	# reduce it to either 1 or -1
	if trackYFirst:
		moveDir = Vector2(0, axisDelta)
	else:
		moveDir = Vector2(axisDelta, 0)

	if moveDir != prevMoveDir and prevMoveDir != Vector2.ZERO:
		hasPassedTarget = true
		if trackYFirst:
			moveDir = (target.position - position).x
		else:
			moveDir = (target.position - position).y
		moveDir /= abs(moveDir)	# reduce it to either 1 or -1
		if trackYFirst:
			moveDir = Vector2(moveDir, 0)
		else:
			moveDir = Vector2(0, moveDir)
		return
	prevMoveDir = moveDir
