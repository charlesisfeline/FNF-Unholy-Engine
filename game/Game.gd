extends Node2D

signal focus_change(is_focused) # when you click on/off the game window

var TRANS = preload('res://game/objects/ui/transition.tscn') # always have it loaded for instantiating
var cur_trans

var persist_vars = {} # var values to remember
var scene = null:
	get: return get_tree().current_scene
	
var screen = [
	ProjectSettings.get_setting("display/window/size/viewport_width"),
	ProjectSettings.get_setting("display/window/size/viewport_height")
]

# fix pause screen because it sets the paused of the tree as well
func _ready():
	focus_change.connect(focus_changed)
	print(scene.name)

var just_pressed:bool = false
var is_full:bool = false

var global_delta:float
func _process(delta):
	global_delta = delta
	if Input.is_key_pressed(KEY_F5):
		reset_scene()
		
	if Input.is_key_pressed(KEY_F6):
		if !just_pressed:
			var window_mode = DisplayServer.WINDOW_MODE_FULLSCREEN if !is_full else DisplayServer.WINDOW_MODE_WINDOWED
			DisplayServer.window_set_mode(window_mode)
			is_full = !is_full
		just_pressed = true
	else: just_pressed = false

func _notification(what):
	if what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN:
		focus_change.emit(true)
	elif what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT:
		focus_change.emit(false)

var is_paused:bool = false:
	set(paus): 
		is_paused = paus
		get_tree().paused = is_paused
func focus_changed(is_focused:bool):
	if Prefs.auto_pause:
		Engine.max_fps = Prefs.fps if is_focused else 12 # no need to process shit if its paused
		Audio.process_mode = Node.PROCESS_MODE_ALWAYS if is_focused else Node.PROCESS_MODE_DISABLED # pausing this is too much work ill just mute it
		if is_focused:
			if is_paused: is_paused = false
		else:
			if !get_tree().paused: is_paused = true

func center_obj(obj = null, axis:String = 'xy') -> void:
	if obj == null: return
	#var obj_size = obj.texture.size()
	if obj is Sprite2D:
		pass

	match axis:
		'x': obj.position.x = (screen[0] / 2) #- (obj_size.x / 2)
		'y': obj.position.y = (screen[1] / 2) #- (obj_size.y / 2)
		_: obj.position = Vector2(screen[0] / 2, screen[1] / 2)

func reset_scene(_skip_trans:bool = false) -> void:
	get_tree().reload_current_scene()

func switch_scene(new_scene, skip_trans:bool = false) -> void:
	if new_scene is String:
		new_scene = new_scene.to_lower()
		if new_scene == 'play_scene' and Prefs.chart_player: new_scene += '_empty'
		var path = 'res://game/scenes/%s.tscn'
		
		if skip_trans:
			get_tree().change_scene_to_file(path % new_scene)
		else:
			if cur_trans != null and cur_trans.in_progress:
				cur_trans.cancel()
				remove_child(cur_trans)
				get_tree().paused = false
				
			get_tree().paused = true
			cur_trans = TRANS.instantiate()
			add_child(cur_trans)
			await cur_trans.trans_out(0.7)
			get_tree().change_scene_to_file(path % new_scene)
			get_tree().paused = false
			cur_trans.trans_in(1, true)
			cur_trans.on_finish = func():
				remove_child(cur_trans)
				cur_trans.queue_free()

	if new_scene is PackedScene:
		get_tree().change_scene_to_packed(new_scene)

# call function on nodes or somethin
func call_func(to_call:String, args:Array[Variant] = [], call_tree:bool = false) -> void:
	if to_call.length() < 1 or scene == null: return
	if call_tree:
		for node in get_tree().get_nodes_in_group(scene.name):
			print(node)
			if node.has_method(to_call):
				node.callv(to_call, args)
	else:
		if scene.has_method(to_call):
			scene.callv(to_call, args)

func format_str(str:String = '') -> String:
	return str.to_lower().strip_edges().replace(' ', '-').replace('\'', '')

func round_d(num, digit) -> float: # bowomp
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
	
func rand_bool(chance:float = 50) -> bool:
	return true if (randi() % 100) < chance else false

func remove_all(array:Array[Array], node = null) -> void:
	if node != null:
		for arr in array:
			while arr.size() != 0:
				node.remove_child(arr[0])
				arr[0].queue_free()
				arr.remove_at(0)

func get_alias(antialiased:bool = true) -> CanvasItem.TextureFilter:
	return CanvasItem.TEXTURE_FILTER_LINEAR if antialiased else CanvasItem.TEXTURE_FILTER_NEAREST
	
func to_time(secs:float, is_milli:bool = true, show_ms:bool = false) -> String:
	if is_milli: secs = secs / 1000
	var time_part1:String = str(int(secs / 60)) + ":"
	var time_part2:int = int(secs) % 60
	if time_part2 < 10:
		time_part1 += "0"

	time_part1 += str(time_part2)
	if show_ms:
		time_part1 += "."
		time_part2 = int((secs - int(secs)) * 100);
		if time_part2 < 10:
			time_part1 += "0"
	
		time_part1 += str(time_part2)
	
	return time_part1
