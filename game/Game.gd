extends Node2D

var scene = null:
	get: return get_tree().current_scene
	
var screen = [
	ProjectSettings.get_setting("display/window/size/viewport_width"),
	ProjectSettings.get_setting("display/window/size/viewport_height")
]

func _ready():
	print(scene.name)

var mo = false
#func _process(_delta):
	#if NOTIFICATION_APPLICATION_FOCUS_IN and mo:
	#	mo = false
	#	print('op')
	#if NOTIFICATION_APPLICATION_FOCUS_OUT and !mo:
	#	mo = true
	#	print('wo')

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

func switch_scene(new_scene, _skip_trans:bool = false):
	if new_scene is String:
		var path = 'res://game/scenes/%s.tscn'
		get_tree().change_scene_to_file(path % new_scene)
	if new_scene is PackedScene:
		get_tree().change_scene_to_packed(new_scene)

func call_func(to_call:String, args:Array = [], _on_scene:bool = true): # call function on nodes or something
	if to_call.length() < 1: return
	#if on_scene:
	if scene.has_method(to_call):
		scene.callv(to_call, args)
	
	#else:
	#	callv(to_call, args)

func round_d(num, digit): # bowomp
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
	
func rand_bool(chance:float = 50):
	return true if (randi() % 100) < chance else false
