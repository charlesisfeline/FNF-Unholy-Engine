extends AnimatedSprite2D

var strum:Strum
const COL = ['purple', 'blue', 'green', 'red']

var on_anim_finish:Callable = func(): queue_free() # if used, set this before you add it with add_child

var _info:Dictionary = {
	'vis'     = ['vis',            [1, 2], 0.65, -20],
	'base'    = ['note impact',    [1, 2], 0.75,   0],
	'haxe'    = ['haxe impact',    [],     0.65,   0],
	'forever' = ['forever impact', [1, 2], 1,      0]
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
	play('%s %s' % anim_ + COL[strum.dir])
	position = strum.position + Vector2(0, _info[spl][3])
	animation_finished.connect(on_anim_finish)
