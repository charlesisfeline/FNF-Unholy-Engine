class_name Strum_Line; extends Node2D;

# DO NOT ADD AS AN OBJECT TO SCENE, NEEDS TO BE INSTANTIATED
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
	if !note.is_sustain or (note.is_sustain and get_strums()[note.dir].anim_timer <= 0):
		strum_anim(note.dir, !is_cpu)
	
	if singer == null: return
	if !note.no_anim:
		if note.type == 'Hey!':
			singer.play_anim('hey', true)
			singer.anim_timer = 0.6
		else:
			if !note.is_sustain or (note.is_sustain and singer.sing_timer <= 0):
				singer.sing(note.dir, note.alt, !note.is_sustain)

func note_miss(note:Note) -> void:
	if singer != null:
		singer.sing(note.dir, 'miss')
	
func strum_anim(dir:int = 0, player:bool = false) -> void:
	var strum:Strum = get_strums()[dir]
	
	strum.play_anim('confirm', true)
	strum.anim_timer = Conductor.step_crochet / 1000.0
	
	if !player:
		strum.reset_timer = Conductor.step_crochet * 1.25 / 1000.0 #0.15
