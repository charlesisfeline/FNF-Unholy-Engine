class_name Character; extends Sprite2D;

var offsets:Dictionary = {
	'idle': [0, 0],
	'singLEFT': [0, 0],
	'singDOWN': [0, 0],
	'singUP': [0, 0],
	'singRIGHT': [0, 0],
	'singLEFTmiss': [0, 0],
	'singDOWNmiss': [0, 0],
	'singUPmiss': [0, 0],
	'singRIGHTmiss': [0, 0]
}
var is_player:bool = false
var hold_timer:float = 0
var cur_character:String = ''

func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !is_player:
		if hold_timer > Conductor.crochet * 0.11:
			hold_timer += delta

func play_anim(anim:String, forced:bool = true):
	pass
