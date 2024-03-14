extends Node2D

var song_list:Array[String] = []
var cur_song:int = 0
var selectable_songs:Array[Label] = []

var i = 0
func _ready():
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
