class_name Strum; extends AnimatedSprite2D;

const dir_array:Array[String] = ['left', 'down', 'up', 'right']
var dir:int = 0
var is_player:bool = false
var downscroll:bool = false
var anim_timer:float = 0
var reset_timer:float = 0

func _ready():
	scale = Vector2(0.7, 0.7)
	play_anim('static')

func _process(delta):
	anim_timer = maxf(anim_timer - delta, 0)
	if reset_timer > 0:
		reset_timer -= delta
		if reset_timer <= 0:
			play_anim('static')

func play_anim(anim:String, forced:bool = false):
	anim = dir_array[dir] + '_' + anim
	if anim == 'static':
		reset_timer = 0
	if forced: frame = 0
	play(anim)
