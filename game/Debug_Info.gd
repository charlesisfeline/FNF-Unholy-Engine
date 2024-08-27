extends CanvasLayer

var time_existed:float = 0.0
var vol_visible:bool = false
var vol_tween:Tween
var max_tween:Tween
var volume:float = 1.0:
	set(vol):
		vol = clamp(vol, 0, 1)
		if vol > volume: 
			Audio.play_sound('vol/up')
		elif vol < volume:
			Audio.play_sound('vol/down')
		else:
			get_node('Volume/BarsBG/VolBar10').modulate = Color.RED
			if max_tween: max_tween.kill()
			max_tween = create_tween()
			max_tween.tween_property(get_node('Volume/BarsBG/VolBar10'), 'modulate', Color.WHITE, 0.3)
			Audio.play_sound('vol/max')
		$Volume.position.y = 0
		vol_visible = true
		time_existed = 0
		AudioServer.set_bus_volume_db(0, linear_to_db(vol))
		volume = vol

@onready var fps_txt = $FPS
func _ready():
	Game.center_obj($Volume, 'x')
	$Volume.position.x -= ($Volume.size.x * $Volume.scale.x) / 2.0

func _process(delta):
	if vol_visible:
		if vol_tween: vol_tween.kill()

		$Volume/Percent.text = str(floor(volume * 100)) +'%'
		for i in 10:
			var bar = get_node('Volume/BarsBG/VolBar'+ str(i + 1))
			bar.scale.y = clamp(lerp(bar.scale.y, 0.0 if floor(volume * 10) <= i else 1.0, delta * 15), 0, 1)
			
		time_existed += delta
		vol_visible = time_existed < 1
		if time_existed >= 1:
			vol_tween = create_tween()
			vol_tween.tween_property($Volume, 'position:y', -100, 0.35)
	
	if Engine: pass
	var mem:String = String.humanize_size(OS.get_static_memory_usage())
	var mem_peak:String = String.humanize_size(OS.get_static_memory_peak_usage())
	fps_txt.text = 'FPS: '+ str(Engine.get_frames_per_second()) +'\n' +'Mem: '+ mem +' / '+ mem_peak
	
func _unhandled_key_input(_event):
	if Input.is_action_just_pressed('vol_up'): volume = min(volume + 0.1, 1)
	if Input.is_action_just_pressed('vol_down'): volume = max(volume - 0.1, 0)
