extends Node2D

var character:Character
var char_json = {}
var anim_list:Array[Label] = []
var offsets:Dictionary = {}

var new_json:Dictionary = {
	'animations': {}
}
var sub_anim:Dictionary = {
	'anim': '', 'offsets': [0, 0]
}

var list:Array = []
var cur_char:String = ''
var selected_id:int = 0

func _ready():
	Game.set_mouse_visibility()
	Audio.play_music('artisticExpression')
	DebugInfo.get_node('FPS').visible = false
	if OS.is_debug_build():
		DebugInfo.get_node('Other').visible = false
		
	character = Character.new(get_viewport_rect().size / 2.0, 'bf', true)
	#character.position -= Vector2(character.width, character.height)
	#character.load_char('bf')
	add_child(character)
	move_child(character, 2)
	
	$UILayer/CharacterSelect.get_popup().connect("id_pressed", on_char_change)
	char_json = JSON.parse_string(FileAccess.open('res://assets/data/characters/bf.json', FileAccess.READ).get_as_text())
	$Cam.position = get_viewport_rect().size / 2.0
	
	list = FileAccess.open('res://assets/data/order.txt', FileAccess.READ).get_as_text().split(',')
	for i in DirAccess.get_files_at('res://assets/data/characters'):
		if !list.has(i.replace('.json', '')):
			list.append(i.replace('.json', ''))
			
	for i in list:
		$UILayer/CharacterSelect.get_popup().add_item(i)
			
func _process(delta):
	$Backdrop.scale = Vector2.ONE / $Cam.zoom
	$Backdrop.position = $Cam.position

	character.speed_scale = $UILayer/AnimSpeed.value
	
	$UILayer/CurData/Anim.text = character.animation
	$UILayer/CurData/Offset.text = str(character.offsets[character.animation])
	$UILayer/CurData/Frame.text = 'Frame:\n'+ str(character.frame) +' / '+ str(character.sprite_frames.get_frame_count(character.animation) - 1)
	

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed('back'): Game.switch_scene('menus/Main_Menu')
	
	if Input.is_action_just_pressed("debug_2"): change_char('gf')
	var ctrl = Input.is_key_pressed(KEY_CTRL)
	var shift = Input.is_key_pressed(KEY_SHIFT)
	## CAMERA ZOOM
	if Input.is_key_pressed(KEY_U): $Cam.zoom -= Vector2(0.01, 0.01)
	if Input.is_key_pressed(KEY_O): $Cam.zoom += Vector2(0.01, 0.01)
	## CAMERA MOVE
	if Input.is_key_pressed(KEY_J): $Cam.position.x -= 5
	if Input.is_key_pressed(KEY_L): $Cam.position.x += 5
	if Input.is_key_pressed(KEY_I): $Cam.position.y -= 5
	if Input.is_key_pressed(KEY_K): $Cam.position.y += 5
	## CHARACTER OFFSETTING
	if Input.is_key_pressed(KEY_LEFT) : $Cam.position.x -= 5
	if Input.is_key_pressed(KEY_RIGHT): $Cam.position.x += 5
	if Input.is_key_pressed(KEY_UP)   : $Cam.position.y -= 5
	if Input.is_key_pressed(KEY_DOWN) : $Cam.position.y += 5
	if Input.is_key_pressed(KEY_SPACE): 
		character.frame = 0
		character.play_anim(character.animation)
		
	if Input.is_key_pressed(KEY_Q):
		character.pause() 
		character.frame -= 1
	if Input.is_key_pressed(KEY_E):
		character.pause()
		character.frame += 1
		
func _on_file_dialog_file_selected(path):
	#$FileDialog.popup_centered()
	var split = path.split('/')
	cur_char = split[split.size()-1].replace('.res', '')
	#char = Character.new([300, 400], cur_char
	#add_child(char)
	#update_anims(char.offsets.keys())
	
func change_char(new_char:String = 'bf'):
	if !ResourceLoader.exists('res://assets/data/characters/'+ new_char +'.json'):
		printerr('Whoops!')
		return
	
	cur_char = new_char
	$UILayer/CharacterSelect/CurCharLabel.text = cur_char
	char_json = JSON.parse_string(FileAccess.open('res://assets/data/characters/'+ new_char +'.json', FileAccess.READ).get_as_text())
	update_anims(char_json.animations)
	character.position = get_viewport_rect().size / 2.0 - Vector2(300, 450)
	character.load_char(new_char)
	#character.position -= Vector2(character.width, character.height)
	
	$Point.position = character.get_cam_pos()

	
func update_anims(anims):
	Game.remove_all([anim_list], $UILayer/Animations)
	offsets.clear()
	
	for i in anims.size():
		var anim = anims[i]
		offsets[anim.anim] = anim.offsets
		var lab = Label.new()
		lab.add_theme_font_override('font', load('res://assets/fonts/vcr.ttf'))
		lab.add_theme_font_size_override('font_size', 20)
		lab.add_theme_constant_override('outline_size', 4)

		lab.position.x -= 20
		lab.position.y = 50 + (20 * i)
		lab.text = anim.anim +' '+ str(anim.offsets)
		
		$UILayer/Animations.add_child(lab)
		anim_list.append(lab)
	
	if anim_list.size() == 0:
		var lab = Label.new()
		lab.add_theme_font_override('font', load('res://assets/fonts/vcr.ttf'))
		lab.add_theme_font_size_override('font_size', 20)
		lab.add_theme_constant_override('outline_size', 4)
		lab.text = 'NO ANIMATIONS'
		lab.modulate = Color.RED
		lab.position.x -= 20
		lab.position.y = 50
		$UILayer/Animations.add_child(lab)
		anim_list.append(lab)
	else:
		selected_id = 0
		anim_list[0].modulate = Color.YELLOW

func on_char_change(id:int):
	var got_char = list[id]
	if cur_char != got_char:
		change_char(got_char)
