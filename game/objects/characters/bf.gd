extends AnimatedSprite2D

var hold_timer:float = 0
var offsets:Dictionary = {
	'idle': [5, 0],
	'singLEFT': [-6, 6],
	'singDOWN': [23, 51],
	'singUP': [46,-32],
	'singRIGHT': [50, 6]
}
func _ready():
	dance()
	
func _process(delta):
	if animation.contains('sing'):
		hold_timer += delta
		if hold_timer >= Conductor.step_crochet * 0.0011 * 4:
			dance()
			hold_timer = 0
			
var anims = ['LEFT', 'DOWN', 'UP', 'RIGHT']
func sing(dir:int = 0):
	play('sing'+ anims[dir])
	frame = 0
	offset.x = offsets['sing'+anims[dir]][0]
	offset.y = offsets['sing'+anims[dir]][1]
	hold_timer = 0
	
func dance():
	play('idle')
	offset.x = offsets['idle'][0]
	offset.y = offsets['idle'][1]
