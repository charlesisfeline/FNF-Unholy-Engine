extends Node2D

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
	['behind_strums', 'bool']
]
#var controls = []

var cur_cata:int = 0
var cur_sub:int = 0
var in_sub:bool = false

var main_text:Array[Alphabet]
var sec_prefs:Array[Alphabet]
func _ready():
	for i in catagories.size():
		var item = catagories[i]
		var text = Alphabet.new(item)
		text.position = Vector2(100, 100 + (100 * i))
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
			if sec_prefs[cur_sub].type == 'bool':
				sec_prefs[cur_sub].update_option()
		else:
			GlobalMusic.play_sound('confirmMenu')
			show_catagory(catagories[cur_cata].to_lower())
				#var pref = get_pref(sec_prefs[cur_sub].text)
				#var val = Prefs.get(pref)
				#Prefs.set(pref, !Prefs.get(pref))
				#sec_prefs[cur_sub].text = pref.capitalize() + ' ' + str(Prefs.get(pref))
				#Prefs.save_prefs()
				#print(Prefs.get(pref))
	if in_sub:
		if Input.is_action_just_pressed('menu_left'):
			if sec_prefs[cur_sub].type == 'array' or sec_prefs[cur_sub].type == 'int':
				sec_prefs[cur_sub].update_option(-1)
		if Input.is_action_just_pressed('menu_right'):
			if sec_prefs[cur_sub].type == 'array' or sec_prefs[cur_sub].type == 'int':
				sec_prefs[cur_sub].update_option(1)
		
	if Input.is_action_just_pressed('menu_up'):
		if in_sub: cur_sub = wrapi(cur_sub - 1, 0, sec_prefs.size())
		else: cur_cata = wrapi(cur_cata - 1, 0, catagories.size())
		update_scroll()
	if Input.is_action_just_pressed('menu_down'):
		if in_sub: cur_sub = wrapi(cur_sub + 1, 0, sec_prefs.size())
		else: cur_cata = wrapi(cur_cata + 1, 0, catagories.size())
		update_scroll()

func show_main():
	in_sub = false
	#cur_cata = 0
	while sec_prefs.size() > 0:
		remove_child(sec_prefs[0])
		sec_prefs[0].queue_free()
		sec_prefs.remove_at(0)
	
	for i in main_text.size():
		main_text[i].modulate.a = 1 if i == cur_cata else 0.6
	
func show_catagory(catagory:String):
	in_sub = true
	cur_sub = 0
	for i in main_text.size():
		main_text[i].modulate.a = 0.8 if i == cur_cata else 0.1

	#main_text[cur_cata].position = Vector2(100, 100)
	var loops:int = 0
	if catagory.to_lower() != 'controls':
		var op_int:int = 0
		for pref in get(catagory):
			#var has_choices = get(catagory)[op_int]
			var new_pref = Option.new(pref)
			#new_pref.text = str(pref).capitalize() + ' ' + str(Prefs.get(pref))
			new_pref.is_menu = true
			new_pref.target_y = loops
			new_pref.lock.x = 550
			new_pref.modulate = Color.BLACK
			add_child(new_pref)
			sec_prefs.append(new_pref)
			loops += 1
		update_scroll()
	else:
		Game.switch_scene('menus/options/change_keybinds')
	

func get_pref(preference:String):
	var fixed_pref:String = preference.to_lower().replace(' ', '_')
	var split = fixed_pref.split('_')
	
	if split.size() > 2:
		fixed_pref = split[0] +'_'+ split[1]
	else:
		fixed_pref = split[0]
	print(fixed_pref)
	return fixed_pref #Prefs.get(fixed_pref)

func update_scroll():
	#GlobalMusic.play_sound('scrollMenu')
	if in_sub:
		for i in sec_prefs.size():
			sec_prefs[i].modulate.a = (1.0 if i == cur_sub else 0.6)
			sec_prefs[i].target_y = i - cur_sub
	else:
		for i in main_text.size():
			main_text[i].modulate.a = (1.0 if i == cur_cata else 0.6)

class Option extends Alphabet:
	var option:String = ''
	var type:String = 'bool' # the option's type: int, bool, array n shit
	var cur_op:int = 0
	var choices:Array = [] # if the option is an array, will hold all possible options
	
	var min_val:float = 0;  var max_val:float = 0
	var cur_val:float = 0
	
	func _init(option_array):#, type:String = 'bool', choices:Array = []):
		option = option_array[0]
		type = option_array[1]
		text = option.capitalize() +' '+ str(Prefs.get(option))
		
		
		if type == 'array':
			choices = option_array[2]
			cur_op = choices.find(str(Prefs.get(option)))
		elif type == 'int' or type == 'float':
			min_val = option_array[2][0]
			max_val = option_array[2][1]
			cur_val = Prefs.get(option)
		
		#if option == null or Prefs.get(option) == null: 
		#	printerr('OPTION: there was an issue with getting the option entered: '+ option)
		
	# update the preference and the option text
	func update_option(diff:float = 0): # diff for arrays/nums
		match type:
			'array':
				cur_op = wrapi(cur_op + round(diff), 0, choices.size())
				var new_val = choices[cur_op]
				Prefs.set(option, new_val)
			'int':
				cur_val = clampi(cur_val + diff, min_val, max_val)
				Prefs.set(option, cur_val)
			'float':
				cur_val = clampf(cur_val + diff, min_val, max_val)
				Prefs.set(option, cur_val)
			'bool': 
				Prefs.set(option, !Prefs.get(option))
			#_: true
		text = option.capitalize() +' '+str(Prefs.get(option))
		Prefs.save_prefs()
