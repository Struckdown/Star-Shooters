extends Node2D


export(String, "health", "time") var phaseSwapMode
export(int) var timeToNextPhase
export(float) var healthPercentToNextPhase
var phaseTracker = 0
var maxPhases

# Called when the node enters the scene tree for the first time.
func _ready():
	owner.connect("tookDamage", self, "updateHealth")
	if phaseSwapMode == "time":
		$Timer.wait_time = timeToNextPhase
		$Timer.start()
	maxPhases = get_child_count()-1
	updatePhase()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func updateHealth(currentFraction):
	if phaseSwapMode == "health" and currentFraction > 0:
		var healthFractionToNextPhase = (float(healthPercentToNextPhase)/100.0)
		phaseTracker = int( (1-currentFraction) / healthFractionToNextPhase ) % maxPhases
		updatePhase()

func updatePhase():
	for child in get_children():
		if child != $Timer:
			child.toggleEmitting(false)
	if get_child_count() > phaseTracker + 1:
		get_child(phaseTracker+1).toggleEmitting(true)


func _on_Timer_timeout():
	phaseTracker = (phaseTracker + 1) % maxPhases
	updatePhase()

func toggleDeath():
	for child in get_children():
		if child != $Timer:
			child.toggleEmitting(false)
