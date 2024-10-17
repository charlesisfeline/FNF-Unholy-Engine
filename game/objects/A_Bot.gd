extends Node2D

const VU_COUNT = 7
const FREQ_MAX = 22000.0

const HEIGHT = 100
const HEIGHT_SCALE = 1.0
const MIN_DB = 100
const ANIMATION_SPEED = 0.1

var spectrum
var min_values = []
var max_values = []

func _draw():
	for i in 7:
		var min_height = min_values[i]
		var max_height = max_values[i] #* AudioServer.get_bus_volume_db(0)
		var height = lerp(min_height, max_height, ANIMATION_SPEED)
	
		#print(height)
		if get_node('VIZ/Bar'+ str(i)) != null:
			get_node('VIZ/Bar'+ str(i)).frame = round((height / (i + 1)))
			# too sensitive, leftmost basically never goes down

var parent = null
var offsets:Vector2 = Vector2.ZERO
func _process(_delta):
	if parent != null: position = parent.position + offsets
	
	var data = []
	var prev_hz = 0

	for i in range(1, VU_COUNT + 1):
		var hz = i * FREQ_MAX / VU_COUNT
		var magnitude = spectrum.get_magnitude_for_frequency_range(prev_hz, hz).length()
		var energy = clampf((MIN_DB + linear_to_db(magnitude)) / MIN_DB, 0, 1)
		var height = energy * HEIGHT * HEIGHT_SCALE
		data.append(height)
		prev_hz = hz

	for i in range(VU_COUNT):
		if data[i] > max_values[i]:
			max_values[i] = data[i]
		else:
			max_values[i] = lerp(max_values[i], data[i], ANIMATION_SPEED)

		if data[i] <= 0.0:
			min_values[i] = lerp(min_values[i], 0.0, ANIMATION_SPEED)

	# Sound plays back continuously, so the graph needs to be updated every frame.
	queue_redraw()

func _ready():
	spectrum = AudioServer.get_bus_effect_instance(0, 0)
	min_values.resize(VU_COUNT)
	max_values.resize(VU_COUNT)
	min_values.fill(0.0)
	max_values.fill(0.0)

func bump(forced:bool = true):
	$Frame.play('bump')
	if forced:
		$Frame.frame = 0
