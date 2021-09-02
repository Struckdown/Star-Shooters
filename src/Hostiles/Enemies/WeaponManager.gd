extends Node2D


export(String, "health", "time", "never") var phaseSwapMode
export(int) var timeToNextPhase
export(float) var healthPercentToNextPhase
var phaseTracker = 0
var maxPhases
var time = 0
var active = true

# Called when the node enters the scene tree for the first time.
func _ready():
	var node = get_parent()
	while not node.has_signal("tookDamage"):
		node = node.get_parent()
	node.connect("tookDamage", self, "updateHealth")
	#	print("Weapon connect failed???")
	if phaseSwapMode == "time":
		$Timer.wait_time = timeToNextPhase
		$Timer.start()
	maxPhases = get_child_count()-1
	updatePhase()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if active:
		if phaseSwapMode != "time":
			return
		time += delta
		if time >= timeToNextPhase:
			time -= timeToNextPhase
			phaseTracker = (phaseTracker + 1) % maxPhases
			updatePhase()

func updateHealth(currentFraction):
	if phaseSwapMode == "health" and currentFraction > 0:
		var healthFractionToNextPhase = (float(healthPercentToNextPhase)/100.0)
		var newPhaseTracker = int( (1-currentFraction) / healthFractionToNextPhase ) % maxPhases
		if newPhaseTracker != phaseTracker:
			phaseTracker = newPhaseTracker
			updatePhase()

func updatePhase():
	for child in get_children():
		if child.has_method("toggleEmitting"):
			child.toggleEmitting(false)
	if get_child_count() > phaseTracker + 1:
		get_child(phaseTracker+1).toggleEmitting(true)


func _on_Timer_timeout():
	return
#	phaseTracker = (phaseTracker + 1) % maxPhases
#	updatePhase()

func toggleDeath():
	for child in get_children():
		if child != $Timer:
			child.toggleEmitting(false)

func toggleEmitting(state):
	for child in get_children():
		if child.has_method("toggleEmitting"):
			child.toggleEmitting(state)
	active = state
