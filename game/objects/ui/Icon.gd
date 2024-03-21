class_name Icon; extends AnimatedSprite2D;

var is_menu:bool = false # for freeplay icons
var char:String = 'face'
var has_lose:bool = false
var is_player:bool = false

func change_icon(char:String = 'face', is_player:bool = false):
	self.is_player = is_player
	play(char)
	if is_player: flip_h = true
	
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_menu: return
	scale.x = lerpf(1, scale.x, exp(-delta * 15))
	scale.y = lerpf(1, scale.y, exp(-delta * 15))
	if get_tree().current_scene.health_bar != null && has_lose:
		var hp = get_tree().current_scene.health_bar.value
		if is_player:
			if hp <= 20:
				frame = 1
			else: frame = 0
		else:
			if hp >= 80:
				frame = 1
			else: frame = 0
