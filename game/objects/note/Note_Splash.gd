extends AnimatedSprite2D

var strum:Strum
const COL = ['purple', 'blue', 'green', 'red']

var on_anim_finish:Callable = func(): queue_free() # if used, set this before you add it with add_child

var _info:Dictionary = {
	'base'    = ['note',    [1, 2], 0.75],
	'haxe'    = ['haxe',    [],     0.65],
	'forever' = ['forever', [1, 2], 1]
}

func _ready():
	var spl = Prefs.splash_sprite
	if Prefs.daniel: spl = 'forever'
	scale = Vector2(_info[spl][2], _info[spl][2]) # 0.95, 0.95
	modulate.a = 0.8 #0.6
	var rand:String = ''
	if !_info[spl][1].is_empty():
		rand = str(randi_range(_info[spl][1][0], _info[spl][1][1]))
		
	var anim_:Array = [_info[spl][0], rand +(' ' if !rand.is_empty() else '')]
	play('%s impact %s' % anim_ + COL[strum.dir])
	position = strum.position
	animation_finished.connect(on_anim_finish)
