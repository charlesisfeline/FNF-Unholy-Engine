class_name Note; extends AnimatedSprite2D;

var strum_time:float
var dir:int = 0
var note_type:String = "":
	set(type): pass

var must_press:bool = false
var can_hit:bool = false
var was_good_hit:bool = false
var too_late:bool = false

var spawned:bool = false
var is_sustain:bool = false
var sustain_length:float = 0
var alpha:float = 1:
	get: return self_modulate.a
	set(alpha): self_modulate.a = alpha
	
const col_array:Array[String] = ['purple', 'blue', 'green', 'red']

func _ready():
	#if not is_sustain:
	scale = Vector2(0.7, 0.7)
	play(col_array[dir] + 'Scroll')
	#self_modulate.a
	pass # Replace with function body.

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
