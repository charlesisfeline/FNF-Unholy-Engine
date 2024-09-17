class_name Strum_Line; extends Node2D;
# DO NOT ADD AS AN OBJECT TO SCENE, NEEDS TO BE INSTANTIATED

var SPLASH = preload('res://game/objects/note/note_splash.tscn')
var SPARK = preload('res://game/objects/note/holdnote_splash.tscn')

@export var is_cpu:bool = true:
	set(cpu): 
		is_cpu = cpu
		for i in get_strums(): i.is_player = !cpu
	
@export var spacing:float = 110.0:
	set(new_space):
		spacing = new_space
		for i in get_strums():
			i.position.x = spacing * i.dir
			
var singer:Character = null
var notes:Array[Note] = []

func _ready():
	for i in 4: # i can NOT be bothered to position these mfs manually
		var cur_strum:Strum = get_strums()[i]
		cur_strum.dir = (i % 4)
		cur_strum.downscroll = Prefs.downscroll
		cur_strum.is_player = !is_cpu
		cur_strum.position.x = spacing * (i % 4)

func get_strums() -> Array[Strum]:
	return [$Left, $Down, $Up, $Right]
	
func note_hit(note:Note) -> void:
	strum_anim(note.dir, !is_cpu, !note.is_sustain)
	
	if singer == null: return
	if !note.no_anim:
		if note.type == 'Hey':
			singer.play_anim('hey', true)
			singer.anim_timer = 0.6
		else:
			singer.sing(note.dir, note.alt, !note.is_sustain)
			
	if Prefs.note_splashes == 'all' or (Prefs.note_splashes == 'sicks' and note.rating == 'sick'):
		spawn_splash(get_strums()[note.dir])

func note_miss(note:Note) -> void:
	if singer != null:
		singer.sing(note.dir, 'miss')
		
func spawn_splash(strum:Strum) -> void:
	var new_splash = SPLASH.instantiate()
	new_splash.strum = strum
	add_child(new_splash)
	new_splash.on_anim_finish = func():
		remove_child(new_splash)
		new_splash.queue_free()
	
func spawn_hold_splash(strum:Strum) -> void:
	pass

func strum_anim(dir:int = 0, player:bool = false, force:bool = true) -> void:
	var strum:Strum = get_strums()[dir]
	
	if force or strum.anim_timer <= 0:
		strum.play_anim('confirm', true)
		strum.anim_timer = Conductor.step_crochet / 1200.0
	
	if !player:
		strum.reset_timer = Conductor.step_crochet * 1.25 / 1000.0 #0.15
