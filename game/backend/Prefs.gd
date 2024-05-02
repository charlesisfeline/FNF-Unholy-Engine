extends Node2D

var cfg_file:ConfigFile = ConfigFile.new()
## GAMEPLAY ##
var auto_play:bool = false
var downscroll:bool = false
var middlescroll:bool = false

var hitsounds:bool = false
var offset:int = 0

var sick_window:int = 45
var good_window:int = 90
var bad_window:int = 135

## VISUALS ##
var fps:int = 60:
	set(new): fps = new; Engine.max_fps = fps
var allow_rpc:bool = true
var note_splashes:String = 'sicks'
var behind_strums:bool = false
var rating_cam:String = 'game'

var daniel:bool = false

## KEYBINDS ##
var note_keys:Array = [
	['A', 'S', 'W', 'D'], ['Left', 'Down', 'Up', 'Right']
	#keybinds for note_left, note_down, note_up, note_right
]
var ui_keys:Array = [
	[['0', '+', '-'], ['', '', '']], # mute, volume up, volume down
	[['A', 'S', 'W', 'D'], ['Left', 'Down', 'Up', 'Right']] # menu navigation
]

#var preferences:Dictionary = {
#	'downscroll': false, 'middlescroll': false, 'splitscroll': false, # scroll types
#	'auto_play': true,
#	'hitsounds': false,
#	'offset': 0,
#	'sick_window': 45, 'good_window': 90, 'bad_window': 135
#}

# Called when the node enters the scene tree for the first time.
func _ready():
	check_prefs()
	
	#save_prefs()
	#load_prefs()
	#set_keybinds()

func set_keybinds():
	var key_names:Array[String] = ['note_left', 'note_down', 'note_up', 'note_right']
	var loops:int = 0
	for key in note_keys[0]:
		var new_key = InputEventKey.new()
		new_key.set_keycode(OS.find_keycode_from_string(key))
		InputMap.action_erase_event(key_names[loops], InputMap.action_get_events(key_names[loops])[0])
		InputMap.action_add_event(key_names[loops], new_key)
		loops += 1
	loops = 0
	
	for key in note_keys[1]:
		var new_key = InputEventKey.new()
		new_key.set_keycode(OS.find_keycode_from_string(key))
		InputMap.action_erase_event(key_names[loops], InputMap.action_get_events(key_names[loops])[1])
		InputMap.action_add_event(key_names[loops], new_key)
		loops += 1
	
func get_list():
	var list = get_script().get_script_property_list()
	list.remove_at(0); list.remove_at(0)

	#for i in list: print(i.name)
	return list

func save_prefs():
	if cfg_file == null: 
		printerr('CONFIG FILE is NOT loaded, couldn\'t save')
		return
		
	for i in get_list():
		cfg_file.set_value('Preferences', i.name, get(i.name))
		
	cfg_file.save('user://data.cfg')
	print('Saved Preferences')
	
func load_prefs():
	var saved_cfg = ConfigFile.new()
	saved_cfg.load('user://data.cfg')
	if saved_cfg.has_section('Preferences'):
		for pref in get_list():
			Prefs.set(pref.name, saved_cfg.get_value('Preferences', pref.name, null))
	return saved_cfg

func check_prefs():
	print('checking')
	var list = get_list()
	var config_exists = FileAccess.file_exists('user://data.cfg')

	if config_exists: 
		var prefs_changed:bool = false
		cfg_file.load('user://data.cfg')
		for pref in list:
			if !cfg_file.has_section_key('Preferences', pref.name):
				prefs_changed = true
				cfg_file.set_value('Preferences', pref.name, get(pref.name))
		if prefs_changed: # if a pref was added, resave the cfg file
			print('prefs changed, updating')
			cfg_file.save('user://data.cfg')
			
		cfg_file = load_prefs()
	else:
		save_prefs()
