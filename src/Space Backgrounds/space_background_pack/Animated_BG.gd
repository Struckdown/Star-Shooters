extends Node

#export(float) var scroll_speed = 0.4
#self.material.set_shader_param("scroll_speed", scroll_speed)
var bigPlanetSpeed = 0.3
var planets = []
var planetSpeeds = [0, 0, 0]
var layerSpeedAllowedRanges = [[0.07,0.14], [0.14, 0.16], [0.12, 0.2]]

func _ready():
	planets.append($"parallax-space-big-planet")
	planets.append($"parallax-space-far-planets")
	planets.append($"parallax-space-ring-planet")
	for i in range(len(planetSpeeds)):
		planetSpeeds[i] = rand_range(layerSpeedAllowedRanges[i][0], layerSpeedAllowedRanges[i][1])
	for i in range(0, len(planets)):
		planets[i].position.x = rand_range(250, 400)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	updatePlanets(delta)


func updatePlanets(d):
	for i in range(0, len(planets)):
		planets[i].position.x -= planetSpeeds[i]
		if planets[i].position.x <= -250:
			planets[i].position.x = rand_range(250, 350)
			planets[i].position.y = rand_range(-80, 80)
			planets[i].rotation_degrees = rand_range(-30, 30)
