class_name Character; extends AnimatedSprite2D;

var json
var offsets:Dictionary = {}
var focus_point:Vector2 = Vector2(0, 0)
var cur_char:String = ''
var char_path:String = ''

var is_player:bool = false
var dance_idle:bool = false
var danced:bool = false
var hold_timer:float = 0
var sing_duration:float = 4

var antialiasing:bool = true:
	set(anti):
		var filter = CanvasItem.TEXTURE_FILTER_LINEAR if anti else CanvasItem.TEXTURE_FILTER_NEAREST
		texture_filter = filter

var dir_anims:Array[String] = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT']
func _init(pos:Array = [0, 0], char:String = 'bf', player:bool = false):
	centered = false
	var split = char.split('-')
	char_path = (split[0]+ '/' +split[1] if split.size() > 1 else char)
	cur_char = char
	is_player = player
	position = Vector2(pos[0], pos[1])
	#focus_point = Vector2(0, 0)
	print('init ' + cur_char)
	
func _ready():
	var path = '/characters/'+ cur_char +'.res'

	if DirAccess.dir_exists_absolute('res://assets/images/characters/'+ char_path):
		path = '/characters/'+ char_path +'/char.res'

	sprite_frames = load('res://assets/images/'+ path)
	if cur_char.ends_with('-pixel'): 
		scale = Vector2(6, 6)
		antialiasing = false

	json = JsonHandler.get_character(cur_char) # get offsets and anim names...
	var lol
	for anim in json.animations:
		offsets[anim.anim] = [-anim.offsets[0], -anim.offsets[1]]
	
	dance_idle = offsets.has('danceLeft')
	dance()

	if !is_player:
		scale.x *= -1
		swap_anim('singLEFT', 'singRIGHT')

func _process(delta):
	#if !is_player:
	if animation.begins_with('sing'):
		hold_timer += delta
		if hold_timer >= Conductor.step_crochet * (0.0011 * sing_duration):
			dance()


func dance(forced:bool = false):
	if dance_idle:
		print('dancei!!!')
		play_anim('dance'+ ('Right' if danced else 'Left'))
		danced = !danced
	else:
		if forced: frame = 0
		play_anim('idle')
	hold_timer = 0

func sing(dir:int = 0, suffix:String = ''):
	frame = 0
	hold_timer = 0
	play_anim(dir_anims[dir] + suffix)
	
func swap_anim(anim1:String, anim2:String):
	var index1 = dir_anims.find(anim1)
	var index2 = dir_anims.find(anim2)
	dir_anims[index1] = anim2
	dir_anims[index2] = anim1

func play_anim(anim:String, forced:bool = true):
	play(anim)
	if offsets.has(anim):
		var anim_offset = offsets[anim]
		if anim_offset.size() == 2:
			offset = Vector2(anim_offset[0], anim_offset[1])

func get_anim(anim:String): # get the animation from the json file
	if json == null: return anim
	for name in json.animations:
		if json.anim == anim: return json.name
	return anim

