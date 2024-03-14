extends Label


var cur_fps:float = 0
func _ready():
	position = Vector2(10, 10)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	cur_fps = Engine.get_frames_per_second()
	text = 'FPS: ' + str(cur_fps)
