extends "res://Hostiles/Enemies/Enemy_Base.gd"

var shieldIsActive = true setget setShield
export(Array, NodePath) var shieldBotSpawners = []
var activeShieldBots = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _ready():
	._ready()
	setShield(false)


func setShield(active:bool):
	shieldIsActive = active
	if active:
		$ShieldRoot/ShieldAnimationPlayer.play("activate")
	else:
		$ShieldRoot/ShieldAnimationPlayer.play_backwards("activate")

func _on_WeaponManager_startedNextHealthPhase():
	requestShields()

func requestShields():
	for child in shieldBotSpawners:
		child = get_node(child)
		child.targetRef = self
		child.startSpawningBot()
		var connections = child.get_signal_connection_list("shieldBotDestroyed")
		if len(connections) <= 0:
			child.connect("shieldBotDestroyed", self, "markShieldBotDestroyed")
	activeShieldBots = len(shieldBotSpawners)
	if activeShieldBots > 0:
		setShield(true)

func markShieldBotDestroyed():
	activeShieldBots -= 1
	if activeShieldBots <= 0:
		activeShieldBots = 0
		setShield(false)


func _on_CheckForShieldsTimer_timeout():
	activeShieldBots = 0
	for bot in shieldBotSpawners:
		if bot.shieldBotRef != null:
			activeShieldBots += 1
	if activeShieldBots <= 0:
		activeShieldBots = 0
		setShield(false)
	$CheckForShieldsTimer.start()
