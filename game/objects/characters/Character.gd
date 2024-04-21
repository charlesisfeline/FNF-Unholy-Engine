class_name Character; extends AnimatedSprite2D;

var json
var offsets:Dictionary = {}
var focus_offsets:Vector2 = Vector2.ZERO # cam offset type shit
var cur_char:String = ''
var icon:String = 'bf'

var idle_suffix:String = ''
var forced_suffix:String = '' # if set, every anim will use it
var special_anim:bool = false
var is_player:bool = false
var dance_idle:bool = false
var danced:bool = false
var dance_beat:int = 2 # dance every %dance_beat%

var hold_timer:float = 0
var sing_duration:float = 4

var width:float = 0:
	get: return width * abs(scale.x)
var height:float = 0:
	get: return height * abs(scale.y)

var antialiasing:bool = true:
	get: return texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST
	set(anti):
		var filter = CanvasItem.TEXTURE_FILTER_LINEAR if anti else CanvasItem.TEXTURE_FILTER_NEAREST
		texture_filter = filter

var sing_anims:Array[String] = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT']
func _init(pos:Vector2 = Vector2.ZERO, char:String = 'bf', player:bool = false):
	centered = false
	var split = char.split('-')
	cur_char = char
	is_player = player
	position = pos
	print('init ' + cur_char)
	
func _ready():
	if !FileAccess.file_exists('res://assets/data/characters/%s.json' % [cur_char]):
		printerr('CHARACTER '+ cur_char +' does NOT have a json')
		cur_char = 'bf'
		
	json = JsonHandler.get_character(cur_char) # get offsets and anim names...
	var path = 'characters/'+ json.image.replace('characters/', '') +'.res'
		
	if !FileAccess.file_exists('res://assets/images/'+ path): # json exists, but theres no res file
		printerr('No .res file found: '+ path)
		path = 'characters/bf/char.res'
		
	sprite_frames = load('res://assets/images/'+ path)
	
	for anim in json.animations:
		offsets[anim.anim] = [-anim.offsets[0], -anim.offsets[1]]
	
	icon = json.healthicon
	scale = Vector2(json.scale, json.scale)
	antialiasing = !json.no_antialiasing #probably gonna make my own char json format eventually
	position.x += json.position[0]
	position.y += json.position[1]
	focus_offsets.x = json.camera_position[0]
	focus_offsets.y = json.camera_position[1]
	
	dance_idle = offsets.has('danceLeft')
	if dance_idle: dance_beat = 1
	if cur_char == 'senpai-angry': forced_suffix = '-alt' # boooo
	
	dance()
	set_stuff()
	
	if !is_player and json.flip_x:
		scale.x *= -1
		position.x += width
		focus_offsets.x -= width / 2
		swap_anim('singLEFT', 'singRIGHT')
		
func _process(delta):
	#if !is_player:
	if !special_anim:
		if animation.begins_with('sing'):
			hold_timer += delta
			if hold_timer >= Conductor.step_crochet * (0.0011 * sing_duration):
				dance()
	else:
		if animation_finished:
			special_anim = false
			dance()

func dance(forced:bool = false):
	if special_anim: return
	if dance_idle:
		play_anim('dance'+ ('Right' if danced else 'Left') + idle_suffix)
		danced = !danced
	else:
		if forced: frame = 0
		play_anim('idle'+ idle_suffix)
	hold_timer = 0

func sing(dir:int = 0, suffix:String = ''):
	hold_timer = 0
	play_anim(sing_anims[dir] + suffix, true)
	
func swap_anim(anim1:String, anim2:String):
	var index1 = sing_anims.find(anim1)
	var index2 = sing_anims.find(anim2)
	sing_anims[index1] = anim2
	sing_anims[index2] = anim1

func play_anim(anim:String, forced:bool = false):
	if forced_suffix.length() > 0: 
		anim += forced_suffix
	if !sprite_frames.has_animation(anim): 
		printerr(anim +' doesnt exist on '+ cur_char)
		return
		
	special_anim = false
	if forced: frame = 0
	play(anim)

	if offsets.has(anim):
		var anim_offset = offsets[anim]
		if anim_offset.size() == 2:
			offset = Vector2(anim_offset[0], anim_offset[1])

func get_cam_pos():
	var midpoint = Vector2(position.x + width / 2, position.y + height / 2)
	var pos:= Vector2(midpoint.x + (-100 if is_player else 150), midpoint.y - 100)
	return pos + focus_offsets
	
func set_stuff():
	var anim:String = 'danceLeft' if dance_idle else 'idle'
	if sprite_frames.has_animation(anim):
		var total:int = sprite_frames.get_frame_count(anim) - 1 # last anim is probably the most upright
		width = sprite_frames.get_frame_texture(anim, total).get_width()
		height = sprite_frames.get_frame_texture(anim, total).get_height()
	
#func get_anim(anim:String): # get the animation from the json file
#	if json == null: return anim
#	for name in json.animations:
#		if json.anim == anim: return json.name
#	return anim
