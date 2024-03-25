extends CanvasLayer

var tween
var def_x = -384
func _ready():
	pass
	#tween = get_tree().create_tween()
	#tween.finished.connect(complete)
	
	#tween.tween_property($dannyboy, "scale:x", 18, 0.2)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	#$dannyboy.position.x = move_toward(def_x, get_viewport().size.x + ($dannyboy.texture.get_width() * $dannyboy.scale.x), delta)

func complete():
	pass
	#tween = get_tree().create_tween()
	#tween.tween_property($dannyboy, "scale:x", 5.984, 1)
	#tween.tween_callback($dannyboy.queue_free)
