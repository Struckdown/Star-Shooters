extends Node2D

# solowDownAndUp means it spends x seconds offline and y seconds online
export(String, "health", "time", "never", "soloDownAndUp") var phaseSwapMode = "never"	# most enemies don't swap by default.
export(int) var timeToNextPhase
export(float) var healthPercentToNextPhase
var phaseTracker = 0
var maxPhases
var timeSinceLastPhase := 0.0
export(bool) var active := true
var processing = true
var weaponManagerParent = null
export(float) var startDelay := 0.0
export(float) var upTime := 5.0
export(float) var downTime = 2
export(bool) var debug = false

signal startedNextHealthPhase

# Called when the node enters the scene tree for the first time.
func _ready():
	var node = get_parent()
	while not node.has_signal("tookDamage") and not node.is_in_group("EnemyBase"):
		node = node.get_parent()
	node.connect("tookDamage", self, "updateHealth")
	#	print("Weapon connect failed???")
	if get_parent().has_method("updatePhase"):
		weaponManagerParent = get_parent()
		active = false
	maxPhases = get_child_count()
	if active:
		updatePhase()	# only activate root


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not processing:
		return
	if startDelay > 0:
		startDelay -= delta
		return
	if weaponManagerParent and not weaponManagerParent.active:
		return
	timeSinceLastPhase += delta
	match phaseSwapMode:
		"soloDownAndUp":
			if active:
				if timeSinceLastPhase >= upTime:
					timeSinceLastPhase = 0
					active = false
					updatePhase()
			else:
				if timeSinceLastPhase >= downTime:
					timeSinceLastPhase = 0
					active = true
					updatePhase()
		"time":
			if active and timeSinceLastPhase >= timeToNextPhase:
				timeSinceLastPhase -= timeToNextPhase
				phaseTracker = (phaseTracker + 1) % maxPhases
				updatePhase()

func updateHealth(currentFraction):
	if phaseSwapMode == "health" and currentFraction > 0 and maxPhases > 0:
		var healthFractionToNextPhase = (float(healthPercentToNextPhase)/100.0)
		var newPhaseTracker = int( (1-currentFraction) / healthFractionToNextPhase ) % maxPhases
		if newPhaseTracker != phaseTracker:
			phaseTracker = newPhaseTracker
			emit_signal("startedNextHealthPhase")
			updatePhase()

func updatePhase():
	if get_child_count() <= 0:
		return
	# Turn all children off
	for child in get_children():
		if child.has_method("updatePhase"):
			child.active = false
			child.updatePhase()
		if child.has_method("toggleEmitting"):
			child.toggleEmitting(false)
	
	if not active:
		return

	# Turn active child on
	var c = get_child(phaseTracker)
	if c.has_method("updatePhase"):
		c.active = true
		c.updatePhase()
	else:
		c.toggleEmitting(active)

func markOwnerAsDestroyed():
	active = false
	updatePhase()

#func toggleEmitting(state):
#	for child in get_children():
#		if child.has_method("toggleEmitting"):	# check if weapon manager or emitter
#			child.toggleEmitting(state)
