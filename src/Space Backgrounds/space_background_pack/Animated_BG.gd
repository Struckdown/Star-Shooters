extends Node2D

#export(float) var scroll_speed = 0.4
#self.material.set_shader_param("scroll_speed", scroll_speed)
var bigPlanetSpeed = 0.3
var planets = []
var planetSpeeds = [0, 0, 0]
var layerSpeedAllowedRanges = [[7,14], [14, 16], [12, 20]]
var colors = ["Red", "Orange", "Green", "Blue"]
export(String, "Red", "Orange", "Green", "Blue") var color = "Red"
export(bool) var useRandomColor = true
export(float) var backgroundSpeedMultiplier
var backgroundSpeedBase
onready var background = $background

func _ready():
	backgroundSpeedBase = $background.material.get_shader_param("scroll_speed")
	planets.append($"parallax-space-big-planet")
	planets.append($"parallax-space-far-planets")
	planets.append($"parallax-space-ring-planet")
	for i in range(len(planetSpeeds)):
		planetSpeeds[i] = rand_range(layerSpeedAllowedRanges[i][0], layerSpeedAllowedRanges[i][1])
	for i in range(0, len(planets)):
		planets[i].position.x = rand_range(250, 400)
	applyHueShift()
	var err = GameManager.connect("graphicsUpdated", self, "refreshBackground")
	if err:
		push_error(err)
	refreshBackground()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta): 
	updatePlanets(delta)


func updatePlanets(d):
	for i in range(0, len(planets)):
		planets[i].position.x -= planetSpeeds[i] * d * (backgroundSpeedMultiplier*0.5)
		if planets[i].position.x <= -250:
			planets[i].position.x = rand_range(250, 350)
			planets[i].position.y = rand_range(-80, 80)
			planets[i].rotation_degrees = rand_range(-30, 30)

func applyHueShift():
	if useRandomColor:
		randomize()
		var i = rand_range(0, 3)
		color = colors[i]
	match color:
		"Red":
			modulate = Color(0.062745, 0.980392, 0.87451)
		"Orange":
			modulate = Color(0.980392, 0.921569, 0.062745)
		"Green":
			modulate = Color(0.133333, 0.980392, 0.062745)
		"Blue":
			modulate = Color(0.062745, 0.980392, 0.87451)

func refreshBackground():
	updateBackgroundSpeed(backgroundSpeedMultiplier)

func updateBackgroundSpeed(_val):
	if not background:
		return
	backgroundSpeedMultiplier = _val
	var newSpeed = backgroundSpeedBase*backgroundSpeedMultiplier*float(GameManager.graphicSettings["BackgroundParallaxEnabled"])
	background.material.set_shader_param("scroll_speed", newSpeed)
	$"parallax-space-stars".material.set_shader_param("scroll_speed",newSpeed)
