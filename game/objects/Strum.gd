class_name Strum; extends AnimatedSprite2D;

const dir_array:Array[String] = ['left', 'down', 'up', 'right']
var dir:int = 0
var is_player:bool = false
var downscroll:bool = false
var reset_timer:float = 0

func _ready():
	scale = Vector2(0.7, 0.7)
	play_anim('static')

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if reset_timer > 0:
		reset_timer -= delta
		if reset_timer <= 0:
			play_anim('static')

func play_anim(anim:String):
	anim = dir_array[dir] + '_' + anim
	if anim == 'static':
		reset_timer = 0
		
	play(anim)
