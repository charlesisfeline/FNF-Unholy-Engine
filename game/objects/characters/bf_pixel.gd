extends AnimatedSprite2D

var hold_timer:float = 0
func _ready():
	dance()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if animation.contains('sing'):
		hold_timer += delta
		if hold_timer >= Conductor.step_crochet * 0.0011 * 4:
			play('idle')
			hold_timer = 0
			
var anims = ['LEFT', 'DOWN', 'UP', 'RIGHT']
func sing(dir:int = 0):
	play('sing'+ anims[dir])
	frame = 0
	hold_timer = 0

func dance():
	play('idle')
