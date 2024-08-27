extends AnimatedSprite2D

var strum
const col = ['purple', 'blue', 'green', 'red']

var _info:Dictionary = {
	'base'    = ['note',    [1, 2], 0.8],
	'haxe'    = ['haxe',    [],     0.8],
	'forever' = ['forever', [1, 2],   1]
}
func _ready():
	var spl = Prefs.splash_sprite
	scale = Vector2(_info[spl][2], _info[spl][2]) # 0.95, 0.95
	modulate.a = 0.8 #0.6
	var rand:String = ''
	if !_info[spl][1].is_empty():
		rand = str(randi_range(_info[spl][1][0], _info[spl][1][1]))
		
	var anim_:Array = [_info[spl][0], rand +(' ' if !rand.is_empty() else '')]
	if Prefs.daniel: anim_ = ['forever', str(randi_range(1, 2)) +' ']
	play('%s impact %s' % anim_ + col[strum.dir])
	position = strum.position

func _on_animation_finished():
	queue_free()
