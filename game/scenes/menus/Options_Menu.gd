extends Node2D

var descriptions
var catagories = ['Gameplay', 'Visuals', 'Controls']

# options that will be in each catagory
# pref name, type, if type is int/float [min_num, max_num], if type is array ['list', 'of', 'choices']
var gameplay = [ 
	['auto_play', 'bool'],
	['downscroll', 'bool'], 
	['middlescroll', 'bool'], 
	['hitsounds', 'bool'],
	['offset', 'int', [0, 300]], 
	['sick_window', 'int', [15, 45]], 
	['good_window', 'int', [15, 90]], 
	['bad_window' , 'int', [15, 135]]
]
var visuals = [
	['fps', 'int', [0, 240]], 
	['allow_rpc', 'bool'], 
	['note_splashes', 'array', ['sicks', 'all', 'none']], 
	['behind_strums', 'bool'],
	['rating_cam', 'array', ['game', 'hud', 'none']],
	['daniel', 'bool']
]
#var controls = []

var cur_cata:int = 0
var sub_option:int = 0
var in_sub:bool = false

var main_text:Array[Alphabet]
var pref_list:Array[Alphabet]
func _ready():
	var b = JSON.new()
	b.parse(FileAccess.open('res://assets/data/prefInfo.json', FileAccess.READ).get_as_text())
	descriptions = b.data
	for i in catagories.size():
		var item = catagories[i]
		var text = Alphabet.new(item)
		text.position = Vector2(275 - (text.width / 2), 100 + (100 * i))
		add_child(text)
		main_text.append(text)
	update_scroll()

func _process(delta):
	if Input.is_action_just_pressed('back'):
		GlobalMusic.play_sound('cancelMenu')
		if in_sub: 
			show_main()
		else:
			Game.switch_scene('menus/main_menu')
	if Input.is_action_just_pressed("accept"):
		if in_sub:
			if pref_list[sub_option].type == 'bool':
				pref_list[sub_option].update_option()
		else:
			GlobalMusic.play_sound('confirmMenu')
			show_catagory(catagories[cur_cata].to_lower())
	if in_sub:
		if Input.is_action_just_pressed('menu_left'):
			if pref_list[sub_option].type == 'array' or pref_list[sub_option].type == 'int':
				pref_list[sub_option].update_option(-1)
		if Input.is_action_just_pressed('menu_right'):
			if pref_list[sub_option].type == 'array' or pref_list[sub_option].type == 'int':
				pref_list[sub_option].update_option(1)
		
	if Input.is_action_just_pressed('menu_up'):
		if in_sub: sub_option = wrapi(sub_option - 1, 0, pref_list.size())
		else: cur_cata = wrapi(cur_cata - 1, 0, catagories.size())
		update_scroll()
	if Input.is_action_just_pressed('menu_down'):
		if in_sub: sub_option = wrapi(sub_option + 1, 0, pref_list.size())
		else: cur_cata = wrapi(cur_cata + 1, 0, catagories.size())
		update_scroll()

func show_main():
	in_sub = false
	#cur_cata = 0
	while pref_list.size() > 0:
		remove_child(pref_list[0])
		pref_list[0].queue_free()
		pref_list.remove_at(0)
	
	$TextBG/Info.text = 'Choose a Catagory'
	for i in main_text.size():
		main_text[i].modulate.a = (1.0 if i == cur_cata else 0.6)
	
func show_catagory(catagory:String):
	in_sub = true
	sub_option = 0
	for i in main_text.size():
		main_text[i].modulate.a = 0.8 if i == cur_cata else 0.1

	#main_text[cur_cata].position = Vector2(100, 100)
	var loops:int = 0
	if catagory.to_lower() != 'controls':
		for pref in get(catagory):
			var new_pref = Option.new(pref, descriptions[pref[0]])
			new_pref.is_menu = true
			new_pref.target_y = loops
			new_pref.lock.x = 1300
			var twen = create_tween()\
			.tween_property(new_pref, 'lock:x', 550, 0.3).set_delay(0.1 * loops)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			
			add_child(new_pref)
			pref_list.append(new_pref)
			loops += 1
		update_scroll()
	else:
		Game.switch_scene('menus/options/change_keybinds')

func update_scroll():
	#GlobalMusic.play_sound('scrollMenu')
	if in_sub:
		for i in pref_list.size():
			pref_list[i].modulate.a = (1.0 if i == sub_option else 0.6)
			pref_list[i].target_y = i - sub_option
		$TextBG/Info.text = pref_list[sub_option].description
	else:
		for i in main_text.size():
			main_text[i].modulate.a = (1.0 if i == cur_cata else 0.6)

class Option extends Alphabet:
	var option:String = ''
	var description:String = 'nothing'
	var type:String = 'bool' # the option's type: int, bool, array n shit
	var check:Checkbox
	
	var cur_op:int = 0
	var choices:Array = [] # if the option is an array, will hold all possible options
	
	var min_val:float = 0;  var max_val:float = 0
	var cur_val:float = 0
	
	func _init(option_array, info:String = 'nothin'):#, type:String = 'bool', choices:Array = []):
		option = option_array[0]
		description = info
		type = option_array[1]
		text = option.capitalize() +' '+ (str(Prefs.get(option)) if type != 'bool' else '')
		
		if type == 'array':
			choices = option_array[2]
			cur_op = choices.find(str(Prefs.get(option)))
		elif type == 'int' or type == 'float':
			min_val = option_array[2][0]
			max_val = option_array[2][1]
			cur_val = Prefs.get(option)
		else:
			check = Checkbox.new()
			add_child(check)
			check.follow_spr = self
			check.checked = Prefs.get(option)
		
		#if option == null or Prefs.get(option) == null: 
		#	printerr('OPTION: there was an issue with getting the option entered: '+ option)
		
	# update the preference and the option text
	func update_option(diff:float = 0): # diff for arrays/nums
		if type == 'int' or type == 'float':
			if Input.is_key_pressed(KEY_SHIFT): diff *= 10
		match type:
			'array':
				cur_op = wrapi(cur_op + round(diff), 0, choices.size())
				Prefs.set(option, choices[cur_op])
			'int':
				cur_val = clampi(cur_val + diff, min_val, max_val)
				Prefs.set(option, cur_val)
			'float':
				cur_val = clampf(cur_val + diff, min_val, max_val)
				Prefs.set(option, cur_val)
			'bool': 
				var a_bool = Prefs.get(option)
				Prefs.set(option, !a_bool)
				check.checked = !a_bool
		if type != 'bool':
			text = option.capitalize() +' '+ str(Prefs.get(option))
		Prefs.save_prefs()
