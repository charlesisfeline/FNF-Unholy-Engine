extends CanvasLayer

@onready var fps_txt = $FPS

func _ready():
	fps_txt.position = Vector2(10, 10)

func _process(_delta):
	var mem:String = String.humanize_size(OS.get_static_memory_usage()).replace('i', '')
	var mem_peak:String = String.humanize_size(OS.get_static_memory_peak_usage()).replace('i', '')
	fps_txt.text = 'FPS: ' + str(Engine.get_frames_per_second())+'\n' + 'Mem: ' + mem + ' / ' + mem_peak
