class_name Checkbox; extends AnimatedSprite2D;

var offsets = [-6, -40]
var is_checked:bool = false:
	set(checked): 
		if checked: 
			play('selected')
			offset = Vector2(offsets[0], offsets[1])
		else:
			play('unselected')
			offset = Vector2.ZERO
		
func _ready():
	pass # Replace with function body.

func _process(delta):
	pass

