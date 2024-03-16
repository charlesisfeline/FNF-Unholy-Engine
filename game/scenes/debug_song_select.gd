extends Node2D

@onready var base_songs:PackedStringArray = FileAccess.open("res://assets/songs/songs.txt", FileAccess.READ).get_as_text().split('\n')
var base_list:Array[String] = []
var song_list:Array[String] = []
var list_list:Array[Array] = []
var cur_list:int = 0
var cur_song:int = 0
var selectable_songs:Array[Label] = []

var downscroll_check:CheckBox
var hitsound_check:CheckBox
var i = 0
func _ready():
	# song list
	for bleh in base_songs: 
		base_list.append(bleh.replace('\r', ''))
	#song_list.append_array(base_songs)
	#print(base_songs)
	for song in DirAccess.get_directories_at('res://assets/songs'):
		if base_list.has(song): continue
		song_list.append(song)
	
	list_list.append(base_list)
	list_list.append(song_list)
	load_list(base_list)
	#print(list_list)
	# pref list
	var txt = Label.new()
	txt.text = 'Downscroll: '
	txt.position = Vector2(800, 150)
	txt.modulate = Color(255, 255, 255)
	add_child(txt)
	
	downscroll_check = CheckBox.new()
	downscroll_check.position.x = txt.position.x + 100
	downscroll_check.position.y = txt.position.y
	downscroll_check.modulate = Color(255, 255, 255)
	downscroll_check.button_pressed = Prefs.get_pref('downscroll')
	add_child(downscroll_check)
	downscroll_check.toggle_mode = true
	downscroll_check.toggled.connect(get_tree().current_scene.downscroll_toggled)
	
	var txt2 = Label.new()
	txt2.text = 'Hitsounds: '
	txt2.position = Vector2(800, 170)
	txt2.modulate = Color(255, 255, 255)
	add_child(txt2)
	
	hitsound_check = CheckBox.new()
	hitsound_check.position.x = txt2.position.x + 100
	hitsound_check.position.y = txt2.position.y
	hitsound_check.modulate = Color(255, 255, 255)
	hitsound_check.button_pressed = Prefs.get_pref('hitsounds')
	add_child(hitsound_check)
	hitsound_check.toggle_mode = true
	hitsound_check.toggled.connect(get_tree().current_scene.hitsound_toggled)
	
	#for pref in Prefs.preferences:
		#pref
		
func load_list(list:Array[String]):
	for item in selectable_songs:
		remove_child(item)
		item.queue_free()
	selectable_songs.clear()
	
	for item in list:
		var song_txt = Label.new()
		song_txt.position = Vector2(100, 100 + (15 * i))
		song_txt.text = item
		selectable_songs.append(song_txt)
		add_child(song_txt)
		if i != 0:
			song_txt.modulate = Color(0, 0, 0)
		i += 1
	i = 0

func _process(delta):
	if Input.is_action_just_pressed("Accept"):
		Conductor.embedded_song = selectable_songs[cur_song].text
		get_tree().change_scene_to_file('res://game/scenes/play_scene.tscn')

	if Input.is_action_just_pressed('ui_down'):
		update_list(1)
	if Input.is_action_just_pressed('ui_up'):
		update_list(-1)
	if Input.is_action_just_pressed('ui_left'):
		switch_list(-1)
	if Input.is_action_just_pressed('ui_right'):
		switch_list(1)

func update_list(amount:int = 0):
	cur_song = wrapi(cur_song + amount, 0, selectable_songs.size())
	for item in selectable_songs:
		item.modulate = Color(255, 255, 255) if cur_song == i else Color(0, 0, 0)
		i += 1
	i = 0

func switch_list(amount:int = 0):
	cur_list = wrapi(cur_list + amount, 0, list_list.size())
	var new_list = list_list[cur_list]
	load_list(new_list)
	update_list()
	
func downscroll_toggled(is_active):
	Prefs.set_pref('downscroll', is_active)

func hitsound_toggled(is_active):
	Prefs.set_pref('hitsounds', is_active)
