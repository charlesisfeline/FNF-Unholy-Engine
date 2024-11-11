extends Node2D

var descriptions
var catagories:Array[String] = ['Gameplay', 'Visuals', 'Controls']
var lerp_points:Array = [-700, 0, 700]

# options that will be in each catagory
# pref name, type, if type is int/float [min_num, max_num], if type is array ['list', 'of', 'choices']
var gameplay = [ 
	['auto_play',        'bool'],
	['legacy_score',     'bool'],
	['ghost_tapping',    'bool'],
	['scroll_type',      'array', ['up', 'down', 'left', 'right', 'middle', 'split']],
	['center_strums',    'bool'],
	['hitsound_volume',   'int', [0, 100]],
	['offset',            'int', [0, 300]], 
	['epic_window',     'float', [15, 22.5]], 
	['sick_window',     'float', [15, 45]], 
	['good_window',     'float', [15, 90]], 
	['bad_window' ,     'float', [15, 135]]
]
var visuals = [
	['fps',             'int', [0, 240]],
	['vsync',         'array', ['disabled', 'enabled', 'adaptive', 'mailbox']],
	['skip_transitions', 'bool'],
	['allow_rpc',      'bool'],
	['basic_play',     'bool'],
	['note_splashes', 'array', ['epics', 'both', 'all', 'none']],
	['splash_sprite', 'array', ['base', 'haxe', 'forever']],
	['behind_strums',  'bool'],
	['rating_cam',    'array', ['game', 'hud', 'none']],
	['auto_pause',     'bool'],
	['chart_grid',     'bool'],
	['daniel',         'bool']
]
#var controls = []

var from_play:bool = false
var cur_option:int = 0
var sub_option:int = 0
var in_sub:bool = false

var main_text:Array[Alphabet]
var pref_list:Array[Alphabet]
func _ready():
	Discord.change_presence('Maining some Menus', 'Checkin some options')
	
	var b = JSON.new()
	b.parse(FileAccess.open('res://assets/data/prefInfo.json', FileAccess.READ).get_as_text())
	descriptions = b.data
	for i in catagories.size():
		var item = catagories[i]
		var text = Alphabet.new(item)
		text.scale = Vector2(0.9, 0.9)
		$Header.add_child(text)
		text.position.y = $Header.size.y / 2.0 - (text.height / 2.0) + 3
		
		var head_size = $Header.size.x
		#if i == 0:
		text.position.x = head_size / 2.0 - (text.width / 2.0)
		#else:
		#	text.position.x = head_size + (text.width)
		main_text.append(text)
	$Description/Text.text = 'Choose a Catagory'
	update_scroll()

func _unhandled_key_input(_event:InputEvent) -> void:
	if in_sub:
		if Input.is_action_just_pressed('menu_up'): update_scroll(-1)
		if Input.is_action_just_pressed('menu_down'): update_scroll(1)
		
		var da_pref = pref_list[sub_option]
		if ['array', 'int', 'float'].has(da_pref.type):
			var update = 1
			if da_pref.type == 'float' and Input.is_key_pressed(KEY_CTRL): update = 0.1
			if Input.is_action_just_pressed('menu_left'): da_pref.update_option(-update)
			if Input.is_action_just_pressed('menu_right'): da_pref.update_option(update)
		if da_pref.type == 'bool' and Input.is_action_just_pressed("accept"): 
			da_pref.update_option()
		if Input.is_action_just_pressed('back'): show_main()
	else:
		if Input.is_action_just_pressed('menu_left'): update_scroll(-1)
		if Input.is_action_just_pressed('menu_right'): update_scroll(1)
			
		if Input.is_action_just_pressed('back'):
			Audio.play_sound('cancelMenu')
			if from_play:
				queue_free()
			else:
				Game.switch_scene('menus/main_menu')
		
		if Input.is_action_just_pressed("accept"):
			show_catagory(catagories[cur_option].to_lower())
	
func _process(_delta):
	#for i in main_text.size():
		#var cata = main_text[i]
		#cata.position.x = lerp(cata.position.x, cata.position.x + lerp_points[i], delta * 0.15)
	pass
	#$Options/Sprite2D.texture.invert = true

	#main_text[0].position.x += 100 * delta


func show_main() -> void:
	Audio.play_sound('cancelMenu')
	in_sub = false
	$Options/SelectBox.visible = false
	#cur_option = 0
	#while pref_list.size() > 0:
	#	$Options.remove_child(pref_list[0])
	#	pref_list[0].queue_free()
	#	pref_list.remove_at(0)
	
	$Description/Text.text = 'Choose a Catagory'
	#for i in main_text.size():
	#	main_text[i].modulate.a = (1.0 if i == cur_option else 0.6)
	
func show_catagory(_catagory:String) -> void:
	Audio.play_sound('confirmMenu')
	in_sub = true
	sub_option = 0
	if catagories[cur_option].to_lower() != 'controls':
		update_scroll()
	else:
		Game.switch_scene('menus/options/change_keybinds')

	return
	#main_text[cur_option].modulate.a = 0.8

	#main_text[cur_option].position = Vector2(100, 100)
	#if catagory.to_lower() == 'controls':
	#	Game.switch_scene('menus/options/change_keybinds')
	#else:
	#	var loops:int = 0
	#	for pref in get(catagory):
	#		var desc = descriptions[pref[0]] if descriptions.has(pref[0]) else 'Missing Description'
	#		var new_pref = Option.new(pref, desc)
	#		new_pref.is_menu = true
	#		new_pref.lock.y = 60 + (75 * loops)
	#		new_pref.target_y = loops
			#var twen = create_tween()\
			#.tween_property(new_pref, 'lock:x', 550, 0.3).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
			
	#		$Options/List.add_child(new_pref)
	#		pref_list.append(new_pref)
	#		loops += 1
	#	update_scroll()

func update_scroll(diff:int = 0) -> void:
	var array:Array = pref_list if in_sub else main_text
	var op:String = 'cur_option' if array == main_text else 'sub_option'

	if diff != 0: Audio.play_sound('scrollMenu')
	set(op, wrapi(get(op) + diff, 0, array.size()))

	$Options/SelectBox.visible = in_sub
	if in_sub:
		$Description/Alert.visible = pref_list[sub_option].type == 'float'
		#var first_y = pref_list[sub_option].position.y
		$Description/Text.text = pref_list[sub_option].description
		var scroll_diff:int = 0
		$Options/SelectBox.position.y = pref_list[sub_option].position.y - 60
		if $Options/SelectBox.position.y < 0:
			scroll_diff -= 1
			#$Options/SelectBox.position.y += 75

		if $Options/SelectBox.position.y > $Options/BG.size.y - 75:
			scroll_diff += 1
			#$Options/SelectBox.position.y -= 75
			
		scroll_diff = clamp(scroll_diff, 0, pref_list.size())
		print($Options/SelectBox.position.y)
		
		$Options/List.position.y = 75 * ($Options/SelectBox.position.y / 75)
		#for i in pref_list:
		#	i.lock.y = 60 + (75 * (i.target_y))
	else:
		for i in array.size():
			array[i].visible = i == cur_option
			
		while pref_list.size() > 0:
			$Options/List.remove_child(pref_list[0])
			pref_list[0].queue_free()
			pref_list.remove_at(0)
		
		var loops:int = 0
		if catagories[cur_option].to_lower() != 'controls':
			for pref in get(catagories[cur_option].to_lower()):
				var desc = descriptions[pref[0]] if descriptions.has(pref[0]) else 'Missing Description'
				var new_pref = Option.new(pref, desc)
				new_pref.is_menu = true
				new_pref.lock.y = 60 + (75 * loops)
				new_pref.target_y = loops
				#var twen = create_tween()\
				#.tween_property(new_pref, 'lock:x', 550, 0.3).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
			
				$Options/List.add_child(new_pref)
				pref_list.append(new_pref)
				loops += 1
			#array[i].modulate.a = (1.0 if i == get(op) else 0.6)
			#if in_sub: array[i].target_y = i - get(op)
		

class Option extends Alphabet:
	var option:String = ''
	var description:String = 'nothing'
	var type:String = 'bool' # the option's type: int, bool, array n shit
	var check:Checkbox
	var test
	
	var cur_op:int = 0
	var choices:Array = [] # if the option is an array, will hold all possible options
	
	var min_val:float = 0;  var max_val:float = 0
	var cur_val:float = 0
	
	func _init(option_array, info:String = 'nothin'):
		option = option_array[0]
		description = info
		type = option_array[1]
		text = option.capitalize()
		lock.x = Game.screen[0] / 2.0 - 500
		scale = Vector2(0.9, 0.9)
		if type != 'bool':
			test = Alphabet.new('Nothing', false)
			add_child(test)
			test.position.x += 750
			
		#color = Color.WHITE
		
		match type:
			'array':
				choices = option_array[2]
				cur_op = choices.find(str(Prefs.get(option)))
				test.text = str(choices[cur_op])
			'int', 'float':
				min_val = option_array[2][0]
				max_val = option_array[2][1]
				cur_val = Prefs.get(option)
				test.text = str(cur_val)
			_:
				check = Checkbox.new()
				add_child(check)
				check.scale = Vector2(0.5, 0.5)
				check.offsets.x += 1030
				check.follow_spr = self
				check.checked = Prefs.get(option)
		
	# update the preference and the option text
	func update_option(diff:float = 0) -> void: # diff for arrays/nums
		match type:
			'array':
				cur_op = wrapi(cur_op + round(diff), 0, choices.size())
				Prefs.set(option, choices[cur_op].to_lower())
			'int', 'float':
				if Input.is_key_pressed(KEY_SHIFT): diff *= 10
				cur_val = clamp(cur_val + diff, min_val, max_val)
				Prefs.set(option, cur_val)
			'bool': 
				var a_bool = Prefs.get(option)
				Prefs.set(option, !a_bool)
				check.checked = !a_bool
		if type != 'bool':
			test.text = str(Prefs.get(option))
		Prefs.save_prefs()
