extends AnimatedSprite2D

var strum
const col = ['purple', 'blue', 'green', 'red']

func _ready():
	#if !Prefs.hold_splash: return
	scale = Vector2(0.8, 0.8) # 0.95, 0.95
	#modulate.a = 0.8 #0.6
	play('holdCoverStart')
	position = strum.position

func _on_animation_finished():
	if animation == 'holdCoverStart':
		pass
	if animation.contains('End'):
		queue_free()
