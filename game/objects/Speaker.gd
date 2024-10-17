class_name Speaker; extends AnimatedSprite2D;

var parent = null
var offsets:Vector2 = Vector2.ZERO
func _init(par = null) -> void:
	centered = false
	sprite_frames = load('res://assets/images/characters/speakers/speaker.res')
	if par != null:
		parent = par

func bump(forced:bool = true) -> void:
	play('bump')
	if forced: frame = 0

func _process(delta:float) -> void:
	if parent != null: position = parent.position + offsets
