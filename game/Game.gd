extends Node2D

signal focus_change(is_focused) # when you click on/off the game window

var TRANS = preload('res://game/objects/ui/transition.tscn') # always have it loaded for instantiating
var cur_trans

var scene = null:
	get: return get_tree().current_scene
	
var screen = [
	ProjectSettings.get_setting("display/window/size/viewport_width"),
	ProjectSettings.get_setting("display/window/size/viewport_height")
]

# make it so the global player runs always UNLESS you dont have focus
# fix pause screen because it sets the paused of the tree as well
func _ready():
	focus_change.connect(focus_changed)
	print(scene.name)

var global_delta:float
func _process(delta):
	global_delta = delta

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
		Audio.volume = 1 if is_focused else 0 # pausing this is too much work ill just mute it
		if is_focused:
			if is_paused: is_paused = false
		else:
			if !get_tree().paused: is_paused = true

func center_obj(obj = null, axis:String = 'xy'):
	if obj == null: return
	#var obj_size = obj.texture.size()
	if obj is Sprite2D:
		pass

	match axis:
		'x': obj.position.x = (screen[0] / 2) #- (obj_size.x / 2)
		'y': obj.position.y = (screen[1] / 2) #- (obj_size.y / 2)
		_: obj.position = Vector2(screen[0] / 2, screen[1] / 2)

func reset_scene(_skip_trans:bool = false):
	get_tree().reload_current_scene()

func switch_scene(new_scene, skip_trans:bool = true):
	if new_scene is String:
		new_scene = new_scene.to_lower()
		if new_scene == 'play_scene' and Prefs.chart_player: new_scene += '_empty'
		var path = 'res://game/scenes/%s.tscn'
		
		if skip_trans:
			get_tree().change_scene_to_file(path % new_scene)
		else:
			cur_trans = TRANS.instantiate()
			add_child(cur_trans)
			cur_trans.trans_out(0.7, true)
			cur_trans.on_finish = func():
				#Game.scene.paused = false
				#Game.remove_child(cur_trans)
				get_tree().change_scene_to_file(path % new_scene)
				cur_trans.trans_in(1, true)
				cur_trans.on_finish = func():
					remove_child(cur_trans)
					cur_trans.queue_free()

	if new_scene is PackedScene:
		get_tree().change_scene_to_packed(new_scene)

func call_func(to_call:String, args:Array[Variant] = [], call_tree:bool = false): # call function on nodes or somethin
	if to_call.length() < 1 or scene == null: return
	if call_tree:
		for node in get_tree().get_nodes_in_group(scene.name):
			print(node)
			if node.has_method(to_call):
				node.callv(to_call, args)
	else:
		if scene.has_method(to_call):
			scene.callv(to_call, args)

func format_str(str:String = ''):
	return str.to_lower().strip_edges().replace(' ', '-').replace('\'', '')

func round_d(num, digit): # bowomp
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
	
func rand_bool(chance:float = 50):
	return true if (randi() % 100) < chance else false

func remove_all(array:Array[Array], node = null):
	if node != null:
		for arr in array:
			while arr.size() != 0:
				node.remove_child(arr[0])
				arr[0].queue_free()
				arr.remove_at(0)
