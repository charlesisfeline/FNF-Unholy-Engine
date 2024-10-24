class_name Character; extends AnimatedSprite2D;

var json
var chart:Array = []
var speaker_data:Dictionary = {}

var offsets:Dictionary = {}
var focus_offsets:Vector2 = Vector2.ZERO # cam offset type shit
@export var cur_char:String = ''
var icon:String = 'bf'
var death_char:String = 'bf-dead'

var is_player:bool = false

var idle_suffix:String = ''
var forced_suffix:String = '' # if set, every anim will use it
var can_dance:bool = true
var looping:bool = false

var dance_idle:bool = false
var danced:bool = false
var dance_beat:int = 2 # dance every %dance_beat%

var hold_timer:float = 0.0
var sing_duration:float = 4.0
var sing_timer:float = 0.0 # for anim looping with sustains

var last_anim:StringName = ''
var special_anim:bool = false:
	set(spec): 
		if spec: last_anim = animation
		special_anim = spec
var anim_timer:float = -1.0: # play an anim for a certain amount of time
	set(time):
		anim_timer = time
		if !special_anim and time > 0:
			special_anim = true
			
var on_anim_finished:Callable = func():
	special_anim = false
	can_dance = true
	dance()
	animation_finished.disconnect(on_anim_finished)

var anim_finished:bool:
	get: return frame == sprite_frames.get_frame_count(animation) - 1
	
var width:float = 0.0:
	get: return width * abs(scale.x)
var height:float = 0.0:
	get: return height * abs(scale.y)

var antialiasing:bool = true:
	get: return texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST
	set(anti):
		texture_filter = Game.get_alias(anti)

var sing_anims:Array[String] = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT']

func _init(pos:Vector2 = Vector2.ZERO, char:String = 'bf', player:bool = false):
	centered = false
	#cur_char = char
	is_player = player
	position = pos
	#print('init ' + char)
	load_char(char)
	
func load_char(new_char:String = 'bf') -> void:
	if new_char == cur_char:
		print(new_char +' already loaded') 
		return
		
	cur_char = new_char
	if !ResourceLoader.exists('res://assets/data/characters/%s.json' % cur_char):
		printerr('CHARACTER '+ cur_char +' does NOT have a json')
		print_rich('[color=red]'+ cur_char +' [color=yellow]-> [color=green]'+ get_closest(cur_char) +'[/color]')
		cur_char = get_closest(cur_char)
	
	json = JsonHandler.get_character(cur_char) # get offsets and anim names...
	var path = 'characters/'+ json.image.replace('characters/', '') +'.res'
		
	if !ResourceLoader.exists('res://assets/images/'+ path): # json exists, but theres no res file
		printerr('No .res file found: '+ path)
		path = 'characters/bf/char.res'
		
	sprite_frames = ResourceLoader.load('res://assets/images/'+ path)
	
	offsets.clear()
	for anim in json.animations:
		offsets[anim.anim] = [-anim.offsets[0], -anim.offsets[1]]
		
	icon = json.healthicon
	scale = Vector2(json.scale, json.scale)
	antialiasing = !json.no_antialiasing #probably gonna make my own char json format eventually
	position.x += json.position[0]
	position.y += json.position[1]
	focus_offsets.x = json.camera_position[0]
	focus_offsets.y = json.camera_position[1]
	
	speaker_data.clear()
	if json.has('speaker'):
		speaker_data = json.speaker
	
	dance_idle = offsets.has('danceLeft') and offsets.has('danceRight')
	if dance_idle: dance_beat = 1
	
	match(cur_char):
		'senpai-angry':
			forced_suffix = '-alt' # boooo
		'pico-speaker':
			can_dance = false
			sing_anims = ['shootLeft', 'shootLeft', 'shootRight', 'shootRight']
			play_anim('shootRight1')
			frame = sprite_frames.get_frame_count('shootRight1') - 4
	
	dance()
	set_stuff()
	
	if cur_char.contains('monster'): swap_sing('singLEFT', 'singRIGHT')
	if (!is_player and json.flip_x) or (is_player and !json.flip_x):
		flip_char()
		
	print('loaded '+ cur_char)

func _process(delta):
	sing_timer = max(sing_timer - delta, 0)
	if special_anim:
		if anim_timer == -1.0:
			if !animation_finished.is_connected(on_anim_finished):
				animation_finished.connect(on_anim_finished)
		else:
			anim_timer = max(anim_timer - delta, 0)
			if anim_timer <= 0.0:
				special_anim = false
				if animation == last_anim:
					dance()
	else:
		if animation.begins_with('sing'):
			hold_timer += delta
			
			var holding = Input.is_action_pressed('note_left') or Input.is_action_pressed('note_down')\
				or Input.is_action_pressed('note_up') or Input.is_action_pressed('note_right')
			
			var boogie = (!is_player or (is_player and !holding)) and can_dance 
			if hold_timer >= Conductor.step_crochet * (0.0011 * sing_duration) and boogie:
				dance()
	
	#if offsets.has(animation +'-loop') and frame == sprite_frames.get_frame_count(animation) - 1:
	#	frame = sprite_frames.get_frame_count(animation) - 4
	#	looping = true
			
	if !chart.is_empty():
		for i in chart: # [0] = strum time, [1] = direction, [2] = is sustain, [3] = length
			if !i[4]: continue
			if i[2]:
				if i[0] <= Conductor.song_pos and i[0] + i[3] > Conductor.song_pos:
					sing(i[1] % 4, '', false)
				if Conductor.song_pos > i[0] + i[3]: # sustain should be finished
					chart.remove_at(chart.find(i))
			else:
				if i[0] <= Conductor.song_pos:
					#var suff:String = str(randi_range(1, 2))
					sing(i[1] % 4, '')
					chart.remove_at(chart.find(i))

func dance(forced:bool = false) -> void:
	if special_anim or !can_dance: return
	#if looping: forced = true
	var idle:String = 'idle'
	if cur_char.contains('-dead'): 
		idle = 'deathLoop'
		forced = true
		
	if dance_idle:
		danced = !danced
		idle = 'dance'+ ('Right' if danced else 'Left')
	
	#modulate.v = 1000
	#test.tween_property(self, 'modulate:v', 1, Conductor.step_crochet / 500.0)
	
	times_danced += 1
	play_anim(idle + idle_suffix, forced)
	hold_timer = 0
	sing_timer = 0

func sing(dir:int = 0, suffix:String = '', reset:bool = true) -> void:
	hold_timer = 0

	if sing_timer == 0:
		sing_timer = 0 if reset else Conductor.step_crochet / 1000.0
		play_anim(sing_anims[dir] + suffix, true)
		#frame = 4


func flip_char() -> void:
	scale.x *= -1
	position.x += width
	focus_offsets.x -= width / 2
	swap_sing('singLEFT', 'singRIGHT')

func swap_sing(anim1:String, anim2:String) -> void:
	var index1 = sing_anims.find(anim1)
	var index2 = sing_anims.find(anim2)
	sing_anims[index1] = anim2
	sing_anims[index2] = anim1

var times_danced:int = 0
func play_anim(anim:String, forced:bool = false, reversed:bool = false) -> void:
	if forced_suffix.length() > 0: 
		anim += forced_suffix
	if !has_anim(anim): 
		printerr(anim +' doesnt exist on '+ cur_char)
		return
	
	looping = false
	special_anim = false
	anim_timer = -1.0
	
	if reversed:
		play_backwards(anim)
	else:
		play(anim)
	if forced: frame = sprite_frames.get_frame_count(anim) - 1 if reversed else 0 

	if offsets.has(anim):
		var anim_offset = offsets[anim]
		if anim_offset.size() == 2:
			offset = Vector2(anim_offset[0], anim_offset[1])
	else:
		offset = Vector2(0, 0)

func get_cam_pos() -> Vector2:
	var midpoint = Vector2(position.x + width / 2, position.y + height / 2)
	var pos:= Vector2(midpoint.x + (-100 if is_player else 150), midpoint.y - 100)
	return pos + focus_offsets
	
func set_stuff() -> void:
	var anim:String = 'danceLeft' if dance_idle else 'idle'
	if has_anim('deathStart') and !has_anim(anim): anim = 'deathStart' # if its a death char
	if has_anim(anim):
		var total:int = sprite_frames.get_frame_count(anim) - 1 # last anim is probably the most upright
		width = sprite_frames.get_frame_texture(anim, 0).get_width()
		height = sprite_frames.get_frame_texture(anim, 0).get_height()

func has_anim(anim:String) -> bool:
	return sprite_frames.has_animation(anim) if sprite_frames != null else false

func copy_char(char:Character) -> Character:
	self.position = char.position
	return Character.new(self.position, self.cur_char, self.is_player)

static func get_closest(char:String = 'bf') -> String: # if theres no character named "pico-but-devil" itll just use "pico"
	for file in DirAccess.get_files_at('res://assets/data/characters'):
		file = file.replace('.json', '')
		if file.to_lower().contains(char): return file
		
	for i in char.split('-'): # get more specific
		for file in DirAccess.get_files_at('res://assets/data/characters'):
			file = file.replace('.json', '')
			if i.to_lower().contains(file): return file
			
	return 'bf'

#func get_anim(anim:String): # get the animation from the json file
#	if json == null: return anim
#	for name in json.animations:
#		if json.anim == anim: return json.name
#	return anim
