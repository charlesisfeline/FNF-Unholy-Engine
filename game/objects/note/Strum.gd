class_name Strum; extends AnimatedSprite2D;

const DIRECTION:Array[String] = ['left', 'down', 'up', 'right']
@export var style:String = 'default'

@export var is_event:bool = false:
	set(ev):
		is_event = ev
		if ev: sprite_frames = load('res://assets/images/ui/eventStrum.res')
		else: load_skin(style)
@export var is_player:bool = false
@export var downscroll:bool = false
@export var dir:int = 0:
	set(new_dir): 
		dir = new_dir
		play_anim('static')
		
var anim_timer:float = 0.0 # used for confirm anim looping on sustains
var reset_timer:float = 0.0
var antialiasing:bool = true:
	get: return texture_filter == CanvasItem.TEXTURE_FILTER_LINEAR
	set(alias):
		antialiasing = alias
		texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR if alias else CanvasItem.TEXTURE_FILTER_NEAREST 

func _ready():
	if !is_event:
		scale = Vector2(0.7, 0.7)
	play_anim('static')

func _process(delta):
	anim_timer = maxf(anim_timer - delta, 0)
	if reset_timer > 0:
		reset_timer -= delta
		if reset_timer <= 0:
			play_anim('static')
			
func load_skin(new_skin = 'default'):
	#var _last = []
	#if !animation.contains('static'):
	#	_last = [animation, frame]
	
	if new_skin is String:
		var style
		if Game.scene.has_node('UI'):
			style = Game.scene.ui.STYLE
		else:
			style = StyleInfo.new()
			style.load_style(new_skin)
		new_skin = style
	
	sprite_frames = new_skin.strum_skin
	scale = new_skin.strum_scale
	antialiasing = new_skin.antialiased
	#if _last.size() > 0:
	#	play_anim(_last[0])
	#	frame = _last[1]
	#else:
	play_anim('static')

func play_anim(anim:String, forced:bool = false):
	if anim == 'static':
		reset_timer = 0
	if !anim.contains(DIRECTION[dir]) and !is_event:
		anim = DIRECTION[dir] +'_'+ anim

	if forced: frame = 0
	play(anim)
