extends Node2D

var credits:Array[Array] = [
	['People I Stole From'],
	['Shadow Mario', 'shadow',  'Psyched Individual', Color.DIM_GRAY, func(): OS.shell_open('https://github.com/ShadowMario')],
	['Zyflx',        'zyflx',  'Boobie Guy', Color(0.24, 0.78, 0.29), func(): OS.shell_open('https://www.youtube.com/@Zyflx')],
	['Crowplexus',   'crow',  'Venha pequena fruta, venha comigo', Color.DARK_RED, func(): OS.shell_open('https://github.com/crowplexus')],
	['Maru',         'empty',  'Very Gay', Color.DARK_RED, func(): print('nothing')],
	['Daniel',       'daniel',    'heieh', Color(0.22, 0.21, 0.34), func(): Prefs.daniel = true],
]

#var credits = [
#	['Test',      'empty',     'He did',                Color.ROSY_BROWN],
#	['Daniel',    'daniel',    'heieh',                 Color(0.22, 0.21, 0.34)],
#	['Doggo',     'doggo',     'guy',   Color(0.51, 0.70, 0.99)],
#	['Moonlight', 'moonlight', 'ga gooberer :flushed:', Color(0.59, 0.31, 0.98)]
#]

var tests = []
var cred_group:Array = []
var cred_desc:Alphabet
var cur_select:int = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	for i in credits:
		var tes = Alphabet.new(i[0])
		tes.is_menu = true
		tes.screen_offset = 75
		tes.spacing.x = 87
		tes.scroll_dir = Alphabet.Scroll.RIGHT_TO_LEFT
		add_child(tes)
		tes.target_y = credits.find(i)
		cred_group.append(tes)
		
		if i.size() > 1:
			var icon = Icon.new()
			icon.change_icon(i[1], false, true)
			add_child(icon)
			icon.follow_spr = tes
	
	cred_desc = Alphabet.new('Empty Empty', false)
	cred_desc.scale = Vector2(0.8, 0.8)
	cred_desc.color = Color.WHITE
	cred_desc.position = Vector2(600, 650)
	add_child(cred_desc)
	update_selection()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _unhandled_key_input(event:InputEvent) -> void:
	if Input.is_action_just_pressed("accept") and credits[cur_select].size() > 4:
		credits[cur_select][4].call()
	if Input.is_action_just_pressed("back"):
		Game.switch_scene('menus/main_menu')
		
	if Input.is_action_just_pressed('menu_up'): update_selection(-1)
	if Input.is_action_just_pressed('menu_down'): update_selection(1)

var col_tween
func update_selection(amount:int = 0) -> void:
	if amount != 0: Audio.play_sound('scrollMenu')
	cur_select = wrapi(cur_select + amount, 0, credits.size())
	
	if credits[cur_select].size() > 1:
		if FileAccess.file_exists('res://assets/images/credits/'+ credits[cur_select][1] +'_img.jpg'):
			$CreditImage.visible = true
			$CreditImage.texture = load('res://assets/images/credits/'+ credits[cur_select][1] +'_img.jpg')
		else:
			$CreditImage.visible = false
		
	cred_desc.text = credits[cur_select][2] if credits[cur_select].size() > 2 else ''
	cred_desc.color = Color.WHITE

	var new_col = credits[cur_select][3] if credits[cur_select].size() > 3 else Color.WHITE
	if col_tween: col_tween.kill()
	col_tween = create_tween()
	col_tween.tween_property($BG, 'modulate', new_col, 0.5)
	
	for i in credits.size():
		var item = cred_group[i]
		item.target_y = i - cur_select
		item.modulate.a = (1.0 if i == cur_select else 0.6)
