extends AudioStreamPlayer

onready var tween_out = get_node("TweenOut")
export var transition_duration = 1.00
export var transition_type = 1 # TRANS_SINE
var requestedSong = ""
var currentSong

# Called when the node enters the scene tree for the first time.
func _ready():
	var val = normalizeValToDB(75)	# Set audio on game startup
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BGM"), val)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), val)
	play()

func transitionSong(newSongPath):
	requestedSong = newSongPath
	fade_out(self)

func normalizeValToDB(val):
	var newVal = 0
	newVal = val*0.5
	newVal -= 50
	return newVal

func normalizeDBtoVal(DB):
	var val = DB + 50
	val *= 2
	return val


func fade_out(stream_player):
	# tween music volume down to 0
	tween_out.interpolate_property(stream_player, "volume_db", 0, -80, transition_duration, transition_type, Tween.EASE_IN, 0)
	tween_out.start()
	# when the tween ends, the music will be stopped

func fade_in(stream_player):
	# tween music volume down to 0
	tween_out.interpolate_property(stream_player, "volume_db", -80, 0, transition_duration, transition_type, Tween.EASE_IN, 0)
	tween_out.start()


func _on_TweenOut_tween_completed(object, _key):
	# stop the music -- otherwise it continues to run at silent volume
	if not requestedSong:
		object.stop()
	if requestedSong != currentSong:
		stream = load(requestedSong)
		object.play()
		fade_in(self)
		currentSong = requestedSong
