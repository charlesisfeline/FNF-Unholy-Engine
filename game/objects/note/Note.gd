class_name Note; extends AnimatedSprite2D;

const col_array:Array[String] = ['purple', 'blue', 'green', 'red']

var spawned:bool = false
var strum_time:float
var dir:int = 0

var holding:bool = false
var missed:bool = false:
	set(miss): if miss: modulate = Color(0, 0, 0, 0.3)

var da:float = 0.7
var end:TextureRect

var speed:float = 1
var type:String = "": 
	set(type): pass

var must_press:bool = false
# god this is long asf but i dont remember if godot lets you
# continue it onto a new line or not
# - Zyflx
var can_hit:bool = false:
	get: return (must_press and strum_time >= Conductor.song_pos - (Conductor.safe_zone * 0.8) and strum_time <= Conductor.song_pos + (Conductor.safe_zone * 1))
var was_good_hit:bool = false:
	get: not must_press and strum_time <= Conductor.song_pos
var too_late:bool = false

# for sustains
var is_sustain:bool = length > 0

var parent:Note
var prev_note:Note
var sustain:TextureRect

var length:float = 0

var hold_offset:float = 0
var offsets:float = 0

	#set(will_be):
	#	alpha = 0.6 if will_be else 1
	#	play(col_array[dir] + ('Hold' if will_be else 'Scroll'))

var alpha:float = 1:
	get: return self_modulate.a
	set(alpha): self_modulate.a = alpha

func _ready():
	scale = Vector2(0.7, 0.7)
	position = Vector2(INF, -INF) # you can see it spawn in for a frame or two
	if !is_sustain:
		play(col_array[dir] + 'Scroll')
	else:
		sustain = TextureRect.new()
		sustain.stretch_mode = TextureRect.STRETCH_TILE
		sustain.texture = load('res://assets/images/ui/notes/'+ '' +'.png')

func _process(_delta):
	# keeping this here because idk if this is important or not - Zyflx
	var safe_zone:float = Conductor.safe_zone
	if must_press:
		if strum_time < Conductor.song_pos - safe_zone and !was_good_hit:
			pass

#func copy_from(note:Note):
#	pass
