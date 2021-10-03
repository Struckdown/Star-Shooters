extends Node2D


export(String, "health", "time", "never") var phaseSwapMode = "never"	# most enemies don't swap by default.
export(int) var timeToNextPhase
export(float) var healthPercentToNextPhase
var phaseTracker = 0
var maxPhases
var time = 0
var active = true
var weaponManagerParent = null
export(bool) var debug = false

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
	if active:
		if weaponManagerParent and not weaponManagerParent.active:
			return
		if phaseSwapMode != "time":
			return
		time += delta
		if time >= timeToNextPhase:
			time -= timeToNextPhase
			phaseTracker = (phaseTracker + 1) % maxPhases
			updatePhase()

func updateHealth(currentFraction):
	if phaseSwapMode == "health" and currentFraction > 0 and maxPhases > 0:
		var healthFractionToNextPhase = (float(healthPercentToNextPhase)/100.0)
		var newPhaseTracker = int( (1-currentFraction) / healthFractionToNextPhase ) % maxPhases
		if newPhaseTracker != phaseTracker:
			phaseTracker = newPhaseTracker
			updatePhase()

func updatePhase():
	# Turn all children off
	for child in get_children():
		if child.has_method("updatePhase"):
			child.active = false
			child.updatePhase()
		else:
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

func toggleDeath():
	push_error("Where is this called from...?")	# this is dumb and should be removed
	for child in get_children():
		child.toggleEmitting(false)

#func toggleEmitting(state):
#	for child in get_children():
#		if child.has_method("toggleEmitting"):	# check if weapon manager or emitter
#			child.toggleEmitting(state)
