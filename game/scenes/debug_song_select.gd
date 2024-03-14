extends Node2D

var song_list:Array[String] = []
var cur_song:int = 0
var selectable_songs:Array[Label] = []

var downscroll_check:CheckBox
var i = 0
func _ready():
	# song list
	for song in DirAccess.get_directories_at('res://assets/songs'):
		song_list.append(song)
		
	for item in song_list:
		var song_txt = Label.new()
		song_txt.position = Vector2(100, 100 + (15 * i))
		song_txt.text = item
		selectable_songs.append(song_txt)
		add_child(song_txt)
		if i != 0:
			song_txt.modulate = Color(0, 0, 0)
		i += 1
	i = 0
	
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
	
	#for pref in Prefs.preferences:
		#pref

func _process(delta):
	if Input.is_action_just_pressed("Accept"):
		Conductor.embedded_song = selectable_songs[cur_song].text
		get_tree().change_scene_to_file('res://game/scenes/play_scene.tscn')

	if Input.is_action_just_pressed('ui_down'):
		update_list(1)
	if Input.is_action_just_pressed('ui_up'):
		update_list(-1)

func update_list(amount:int = 0):
	cur_song = wrapi(cur_song + amount, 0, selectable_songs.size())
	for item in selectable_songs:
		item.modulate = Color(255, 255, 255) if cur_song == i else Color(0, 0, 0)
		i += 1
	i = 0

func downscroll_toggled(is_active):
	Prefs.set_pref('downscroll', is_active)
