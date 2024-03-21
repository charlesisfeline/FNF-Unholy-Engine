class_name Note; extends AnimatedSprite2D;

const col_array:Array[String] = ['purple', 'blue', 'green', 'red']

var spawned:bool = false
var strum_time:float
var dir:int = 0

var type:String = "": 
	set(type): pass

var must_press:bool = false
var can_hit:bool = false
var was_good_hit:bool = false
var too_late:bool = false

# for sustains
var sustain:TextureRect

var prev_note:Note
const SUSTAIN_SIZE:int = 44
var sustain_length:float = 0
var is_sustain:bool = false
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
		pass

func _process(delta):
	var safe_zone:float = Conductor.safe_zone
	if must_press:
		can_hit = (Conductor.song_pos - (safe_zone * 0.8) and strum_time <= Conductor.song_pos + (safe_zone * 1))
		
		if strum_time < Conductor.song_pos - safe_zone and !was_good_hit:
			pass
	else:
		can_hit = false
		if(strum_time <= Conductor.song_pos): #is_sustain && prev_note.wasGoodHit) || 
			was_good_hit = true

func copy_from(note:Note):
	pass
