extends Node2D

var sec_title:Alphabet
var notif:Alphabet = Alphabet.new('Press a key for: ')
var bg_box:ColorRect
var changing_key:bool = false
var can_accept_input:bool = false
var selected_bind:String = ''
var alt:int = 0 # for getting the first or second bind of a key
var key_names:Array = ['left', 'down', 'up', 'right']

var cur_menu:String = ''
var cur_bind:int = 0
var key_binds:Array = []
var strums:Array[Strum]
const DEFAULT_KEYS = [['A', 'S', 'W', 'D'], ['Left', 'Down', 'Up', 'Right']]

func _ready():
	sec_title = Alphabet.new()
	sec_title.position = Vector2(450, 110)
	add_child(sec_title)
	
	bg_box = ColorRect.new()
	bg_box.color = Color(0, 0, 0, 0.7)
	bg_box.custom_minimum_size = Vector2(Game.screen[0] + 10, Game.screen[1] + 10)
	bg_box.position = Vector2(-5, -5)
	$Over.add_child(bg_box)
	bg_box.visible = false
	
	notif.scale = Vector2(0.7, 0.7)
	notif.position = Vector2(200, 200)
	$Over.add_child(notif)
	notif.visible = false
	swap_menu('note')
	$SelectBox.scale = Vector2(3, 1.2)
	update_selection()
	
	for i in 4:
		var temp_strum = Strum.new()
		temp_strum.load_skin('default')
		temp_strum.position = Vector2(470 + (200 * i), 550)
		temp_strum.dir = i
		add_child(temp_strum)
		strums.append(temp_strum)

func _unhandled_key_input(event:InputEvent):
	if Input.is_action_just_pressed("back"):
		if changing_key:
			toggle_change('', false)
		else:
			Prefs.set_keybinds()
			Game.switch_scene('menus/options_menu')
			
	if !changing_key:
		if Input.is_key_pressed(KEY_R):
			Prefs.note_keys = [['A', 'S', 'W', 'D'],['Left', 'Down', 'Up', 'Right']]
			Prefs.set_keybinds()
			swap_menu('note')
			
		if Input.is_action_just_pressed('menu_left') : update_selection(-1)
		if Input.is_action_just_pressed('menu_right'): update_selection(1)
		if Input.is_action_just_pressed('menu_down') : update_selection(4)
		if Input.is_action_just_pressed('menu_up')   : update_selection(-4)
	
		if Input.is_action_just_pressed("accept") and key_binds[cur_bind] != null:
			toggle_change(cur_menu +'_'+ key_names[cur_bind % 4])
			
	if changing_key:
		if !selected_bind.is_empty() and can_accept_input and !event.is_released():
			var old_key = key_binds[cur_bind].text
			var key_name = OS.get_keycode_string(event.keycode)
			
			var old_event:InputEvent = InputMap.action_get_events(selected_bind)[alt]
			if InputMap.action_has_event(selected_bind, old_event):
				InputMap.action_erase_event(selected_bind, old_event)
	
			var new_key = InputEventKey.new()
			new_key.set_keycode(event.keycode)
			InputMap.action_add_event(selected_bind, new_key)
	
			print('Keybinds: '+ selected_bind +'['+ str(alt) +'] changed ('+ old_key +' -> '+ key_name +')')
			
			Prefs.note_keys[alt][cur_bind % 4] = key_name
			#print(Prefs.note_keys)
			Prefs.save_prefs()
			
			key_binds[cur_bind].text = key_name
			
			toggle_change('', false)
	
func update_selection(amount:int = 0) -> void:
	cur_bind = wrapi(cur_bind + amount, 0, key_binds.size())
	alt = 0 if cur_bind < floor(key_binds.size() / 2) else 1
	$SelectBox.position = key_binds[cur_bind].position - Vector2(10, 60)
	
func toggle_change(bind:String = '', on:bool = true) -> void:
	if !bind.is_empty():
		notif.text = 'Press a key for: '+ bind.capitalize()
	selected_bind = bind
	notif.visible = on
	bg_box.visible = on
	changing_key = on
	if on:
		await get_tree().create_timer(0.1).timeout
		can_accept_input = true
	else:
		can_accept_input = false
	
func swap_menu(to_keys:String = 'note') -> void:
	var colum:int = 0
	var rows:int = 0
	var _binds
	cur_menu = to_keys
	sec_title.text = to_keys.capitalize() + ' Keys'
	sec_title.position.x = Game.screen[0] / 2 - (sec_title.width / 2)
	
	while key_binds.size() != 0:
		remove_child(key_binds[0])
		key_binds[0].queue_free()
		key_binds.remove_at(0)
		
	if to_keys.to_lower() == 'vol' : _binds = Prefs.ui_keys[0]
	if to_keys.to_lower() == 'menu': _binds = Prefs.ui_keys[1]
	if to_keys.to_lower() == 'note': _binds = Prefs.note_keys
			
	for strum in strums: 
		strum.visible = to_keys == 'note'
	for _set in _binds:
		for key in _set:
			if key.is_empty(): key = 'None'
			var new_key = Alphabet.new(key, false)
			new_key.modulate = Color.BLACK
			new_key.position = Vector2(400 + (200 * colum), 300 + (100 * rows))
			key_binds.append(new_key)
			add_child(new_key)
			colum += 1
		colum = 0; rows += 1;

	var set1 = Alphabet.new('Set 1')
	set1.position = key_binds[0].position - Vector2(300, 50)
	add_child(set1)
		
	var set2 = Alphabet.new('Set 2')
	set2.position = key_binds[4].position - Vector2(300, 50)
	add_child(set2)
