extends Node2D
# Contains data between levels

var score = 0
var playerLives = 3
var stage = null

func _ready():
	pass

func resetGame():
	score = 0
	playerLives = 3
	stage = null
