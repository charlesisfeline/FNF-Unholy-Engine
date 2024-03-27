class_name ComboNums; extends Sprite2D;

var id:int = 0
var init_pos:Vector2
func _ready():
	scale = Vector2(0.4, 0.4)
	position = Vector2(620, 350)
	init_pos = position
	
	await get_tree().create_timer(Conductor.crochet * 0.002).timeout
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.2)
	tween.tween_callback(self.queue_free)
	
func _process(_delta):
	pass
