extends Label


var cur_fps:float = 0
func _ready():
	position = Vector2(10, 10)

func _process(delta):
	cur_fps = Engine.get_frames_per_second()
	
	var mem:String = String.humanize_size(OS.get_static_memory_usage()).replace('i', '')
	var mem_peak:String = String.humanize_size(OS.get_static_memory_peak_usage()).replace('i', '')
	text = 'FPS: ' + str(cur_fps)+'\n' + 'Mem: ' + mem + ' | ' + mem_peak
