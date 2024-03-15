class_name Sustain; extends TextureRect;

var parent:Note
var dir:int = 0
var length:float = 0
var spawned:bool = false
var must_press:bool = false
var strum_time:float = 0
var da:float = 0.7

func _ready():
	texture = load('res://assets/images/ui/notes/blue_hold.png')
	stretch_mode = TextureRect.STRETCH_TILE
	scale = Vector2(0.7, 0.7)

func _process(_delta):
	scale.y = move_toward(scale.y, da, _delta * 5000)
	if parent != null:
		position.x = (parent.position.x + parent.scale.x * 0.5) - 20

func le_scale(scl:float = 0.7):
	scale.y = scl
