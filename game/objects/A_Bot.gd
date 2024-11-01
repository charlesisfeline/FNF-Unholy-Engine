extends Node2D

const VU_COUNT = 7
const FREQ_MAX = 22000.0

const HEIGHT = 100
const HEIGHT_SCALE = 1.0
const MIN_DB = 60
const ANIMATION_SPEED = 0.1

@onready var spectrum = AudioServer.get_bus_effect_instance(1, 0)
var min_values = []
var max_values = []

var parent = null
var offsets:Vector2 = Vector2.ZERO
func _process(_delta):
	if parent != null: position = parent.position + offsets
	
	var prev_hz:float = 0;
	for i in range(0, 7):
		var hz = i * 11050.0 / 7; # thank you y i will mess with it later
		var energy = clamp((60.0 + linear_to_db(spectrum.get_magnitude_for_frequency_range(prev_hz, hz).length())) / 60.0, 0, 1)
		get_node('VIZ/Bar'+ str(i)).frame = clamp(round(5 - (energy * 5)), 0, 5)
		prev_hz = hz
	
func bump(forced:bool = true):
	$Frame.play('bump')
	if forced:
		$Frame.frame = 0

var eye_tween:Tween
func look(left:bool = false):
	var tween_to:float = 0 if left else 111
	$Eyes.position.x = 111
