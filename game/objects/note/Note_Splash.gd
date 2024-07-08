extends AnimatedSprite2D

var strum
const col = ['purple', 'blue', 'green', 'red']
func _ready():
	scale = Vector2(0.9, 0.9) # 0.95, 0.95
	modulate.a = 0.8 #0.6
	var anim_:Array = ['haxe', ''] if Prefs.splash_sprite == 'haxe' else ['note', str(randi_range(1, 2))+ ' ']
	play('%s impact %s' % anim_ + col[strum.dir])
	position = strum.position

func _on_animation_finished():
	queue_free()
