class_name Note; extends Node2D;

const col_array:Array[String] = ['purple', 'blue', 'green', 'red']

var spawned:bool = false
var strum_time:float
var dir:int = 0

var must_press:bool = false
var speed:float = 1
var type:String = "": 
	set(type): pass

var can_hit:bool = false#:
#	get: return (must_press and strum_time >= Conductor.song_pos - (Conductor.safe_zone * 0.8)\
#	and strum_time <= Conductor.song_pos + (Conductor.safe_zone * 1))
	
var was_good_hit:bool = false#:
#	get: return not must_press and strum_time <= Conductor.song_pos
var too_late:bool = false

var length:float = 0
var is_sustain:bool = false

var alpha:float = 1:
	get: return modulate.a
	set(alpha): modulate.a = alpha

func _init(data:NoteData):
	if data != null:
		strum_time = data.strum_time
		dir = data.dir
		length = data.length
		must_press = data.must_press
		#if length > 100:

func _ready():
	spawned = true
	scale = Vector2(0.7, 0.7)
	position = Vector2(INF, -INF) # you can see it spawn in for a frame or two
	if is_sustain:
		texture = load('res://assets/images/ui/notes/'+ col_array[dir] +'Hold')
	else:
		texture = load('res://assets/images/ui/notes/'+ col_array[dir] +'Scroll')

func _process(_delta):
	var safe_zone:float = Conductor.safe_zone
	if must_press:
		can_hit = (Conductor.song_pos - (safe_zone * 0.8) and strum_time <= Conductor.song_pos + (safe_zone * 1))
		
		if strum_time < Conductor.song_pos - safe_zone and !was_good_hit:
			pass
	else:
		can_hit = false
		if(strum_time <= Conductor.song_pos):
			was_good_hit = true

func follow_song_pos(strum:Strum):
	var pos:float = (0.45 * (Conductor.song_pos - strum_time) * speed)
	if !strum.downscroll: pos *= -1
	
	position.x = strum.position.x
	position.y = strum.position.y + pos
