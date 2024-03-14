class_name Sustain; extends TextureRect;

var parent:Note
var length:float = 0
var spawned:bool = false
var must_press:bool = false
var strum_time:float = 0
func _ready():
	texture = load('res://assets/images/ui/notes/blue_hold.png')
	stretch_mode = TextureRect.STRETCH_TILE
	scale = Vector2(0.7, 0.7)

func _process(_delta):
	if parent != null:
		position = Vector2((parent.position.x + parent.scale.x * 0.5) - 20, parent.position.y + parent.scale.y * 0.5)
