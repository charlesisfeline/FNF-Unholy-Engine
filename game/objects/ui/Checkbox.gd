class_name Checkbox; extends AnimatedSprite2D;

var follow_spr = null
var offsets:Array[int] = [-6, -39]
var checked:bool = false:
	set(checked):
		play(('un' if !checked else '') +'selected')
		offset = Vector2(offsets[0], offsets[1]) if checked else Vector2.ZERO
			
func _init():
	sprite_frames = load('res://assets/images/checkbox.res')

func _process(_delta):
	if follow_spr != null:
		position.x = follow_spr.position.x - 15
		position.y = -25 #follow_spr.position.y + follow_spr.height / 2
