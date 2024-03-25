class_name Sustain; extends TextureRect;

var parent:Note
var strum_time:float = 0
var dir:int = 0
var length:float = 0

var hold_offset:float = 0
var offset:float = 0
var spawned:bool = false
var must_press:bool = false
var can_hit:bool = false

var holding:bool = false
var was_good_hit:bool = false
var missed:bool = false:
	set(miss): if miss: modulate = Color(0, 0, 0, 0.3)

var da:float = 0.7
var end:TextureRect = TextureRect.new()

@onready var game = get_tree().current_scene
const col = ['purple', 'blue', 'green', 'red']
func _ready():
	modulate.a = 0.6
	stretch_mode = TextureRect.STRETCH_TILE
	scale = Vector2(0.7, 0.7)

func _process(delta):
	scale.y = da
	if parent != null:
		position.x = (parent.position.x + parent.scale.x * 0.5) - 20
	
	#for auto and opponent 
	can_hit = strum_time <= Conductor.song_pos
	if can_hit: 
		hold_offset += delta * (game.SONG.speed * 450)
		if game.auto_play or !must_press:
			holding = true
	if holding:
		cut(Conductor.song_pos - strum_time - length)
		offset = -hold_offset if Prefs.get_pref('downscroll') else hold_offset

func copy_parent():
	if parent != null:
		spawned = true #if it's copying from the parent, then it's spawned
		strum_time = parent.strum_time
		dir = parent.dir
		must_press = parent.must_press
		length = parent.sustain_length
	texture = load("res://assets/images/ui/notes/"+ col[dir] +"_hold.png")

func cut(mills:float):
	da = (absf(mills) / 50) * 0.45 * game.SONG.speed
	if Prefs.get_pref('downscroll'): da *= -1
	if abs(mills) <= 1 or (Conductor.song_pos - strum_time) > length: # sustain would go on forever
		was_good_hit = true
