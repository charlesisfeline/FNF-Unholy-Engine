extends Node2D

var hot:Character 
var anims = ['idle', 'singLEFT', 'singDOWN', 'singUP', 'singRIGHT']
func _ready():
	hot = Character.new([200, 200], 'oruta')
	add_child(hot)
	
var o = 0
var i = 0
func _process(delta):
	o += delta
	if o >= 0.5:
		o = 0
		i = wrapi(i + 1, 0, 5)
		hot.play_anim(anims[i])
