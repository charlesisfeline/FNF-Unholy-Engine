extends Node2D

var best_scores = ConfigFile.new()
@onready var order = FileAccess.open('res://assets/data/weeks/week-order.txt', FileAccess.READ).get_as_text().split('\n')
var added_songs:Array[String] = [] # a list of all the song names, so no dupes are added
var added_weeks:Array[String] = [] # same but for week jsons

var diff_list = JsonHandler.base_diffs
var diff_int:int = 1
var diff_str:String = 'normal'

var last_loaded:Dictionary = {song = '', diff = ''}
var cur_song:int = 0
var songs:Array[FreeplaySong] = []
var icons:Array[Icon] = []
func _ready():
	if Audio.Player.stream == null:
		Audio.play_music('freakyMenu', true, 0.7)
	Discord.change_presence('Maining some Menus', 'In Freeplay')
	
	if order != null: 
		for file in order: # base songs first~
			added_weeks.append(file.strip_edges())
			var week_file = JsonHandler.parse_week(file)
			var d_list = week_file.difficulties if week_file.has('difficulties') else []
			for song in week_file.songs:
				add_song(FreeplaySong.new(song, d_list))
	
	# you dont need a json to add songs, without one itll only have base 3 diffs, no color, and a bf icon
	var weeks_to_add = []
	for week in DirAccess.get_files_at('res://assets/data/weeks'):
		week = week.replace('.json', '')
		if !added_weeks.has(week) and !week.ends_with('.txt'):
			weeks_to_add.append(week)
	
	if weeks_to_add.size() > 0:
		for week in weeks_to_add:
			var week_file = JsonHandler.parse_week(week)
			var d_list = week_file.difficulties if week_file.has('difficulties') else []
			for song in week_file.songs:
				add_song(FreeplaySong.new(song, d_list))
	
	for song in DirAccess.get_directories_at('res://assets/songs'):
		add_song(FreeplaySong.new([song, 'bf', [100, 100, 100]]))
	
	HighScore.init_save()
	#update_save() # changed who it works

	if JsonHandler._SONG.has('song'):
		last_loaded.song = Game.format_str(JsonHandler._SONG.song)
		last_loaded.diff = JsonHandler.get_diff
		cur_song = added_songs.find(last_loaded.song)
	
	update_list()
	
func add_song(song:FreeplaySong) -> void:
	var song_name:String = Game.format_str(song.song)
	if added_songs.has(song_name):
		#print_rich("[color=yellow]"+ song.song +"[/color] already added, skipping")
		song.queue_free()
		return
		
	added_songs.append(song_name)
	add_child(song)
	songs.append(song)

	var icon = Icon.new()
	add_child(icon)
	icon.change_icon(song.icon)
	icon.is_menu = true
	icon.follow_spr = song
	icons.append(icon)

var lerp_score:int = 0
var actual_score:int = 2384397

func _process(delta):
	lerp_score = floor(lerp(actual_score, lerp_score, exp(-delta * 24)))
	if abs(lerp_score - actual_score) <= 10:
		lerp_score = actual_score
		
	$SongInfo/Score.text = 'Best Score: '+ str(lerp_score)
	$SongInfo/Score.position.x = Game.screen[0] - $SongInfo/Score.size[0] - 6
	$SongInfo/ScoreBG.scale.x = Game.screen[0] - $SongInfo/Score.position.x + 6
	$SongInfo/ScoreBG.position.x = Game.screen[0] - ($SongInfo/ScoreBG.scale.x / 2)
	
	$SongInfo/Difficulty.position.x = int($SongInfo/ScoreBG.position.x + ($SongInfo/ScoreBG.size[0] / 2))
	$SongInfo/Difficulty.position.x -= ($SongInfo/Difficulty.size[0] / 2) + 150
	$SongInfo/ScoreBG.position.x -= 215
	
	#if Input.is_physical_key_pressed(KEY_TAB) and wait_time <= 0:
	#	wait_time = 1
	#	switch_list()

var col_tween
func update_list(amount:int = 0) -> void:
	if amount != 0: Audio.play_sound('scrollMenu')
	cur_song = wrapi(cur_song + amount, 0, songs.size())
	
	if col_tween: col_tween.kill()
	col_tween = create_tween()
	col_tween.tween_property($MenuBG, 'modulate', songs[cur_song].bg_color, 0.3)
	
	diff_list = songs[cur_song].diff_list
	change_diff()
	
	for i in songs.size():
		var item = songs[i]
		item.target_y = i - cur_song
		item.modulate.a = (1.0 if i == cur_song else 0.6)

func change_diff(amount:int = 0) -> void:
	#diff_list = JsonHandler.get_diffs #something for later i suppose
	diff_int = wrapi(diff_int + amount, 0, diff_list.size())
	diff_str = diff_list[diff_int]
	var text = '< '+ diff_str.to_upper() +' >'
	if diff_list.size() == 1: text = text.replace('<', ' ').replace('>', ' ')
	actual_score = HighScore.get_score(added_songs[cur_song], diff_str)
	$SongInfo/Difficulty.text = text

func _unhandled_key_input(event):
	var shifty = Input.is_key_pressed(KEY_SHIFT)
	var diff:int = 4 if shifty else 1
	var is_pressed:Callable = func(action): 
		return Input.is_action_just_pressed(action) or Input.is_action_pressed(action)
		
	if Input.is_key_pressed(KEY_R):
		print('Erasing '+ ('all' if shifty else diff_str) +' | '+ songs[cur_song].text)
		HighScore.clear_score(songs[cur_song].text, diff_str, shifty)
		update_list()
	if is_pressed.call('menu_down') : update_list(diff)
	if is_pressed.call('menu_up')   : update_list(-diff)
	if is_pressed.call('menu_left') : change_diff(-1)
	if is_pressed.call('menu_right'): change_diff(1)
	
	if Input.is_action_just_pressed('back'):
		Audio.play_sound('cancelMenu')
		Game.switch_scene('menus/main_menu')
		
	if Input.is_action_just_pressed('accept'):
		Audio.stop_music()
		Conductor.reset()
		if last_loaded.song != songs[cur_song].text or last_loaded.diff != diff_str:
			JsonHandler.parse_song(songs[cur_song].text, diff_str, true)
		JsonHandler.song_diffs = songs[cur_song].diff_list
		Game.switch_scene('play_scene')
	
func update_save() -> void: # update the file with any new songs/difficulties
	#NOTE rather than go over every single song every time you enterr freeplay 
	# (which only happened because of the old system)
	# it now only saves the song once you actually play and beat it
	# i will still keep this here, maybe for the future
	#if ResourceLoader.exists('user://highscores.cfg'):
	#	best_scores.load('user://highscores.cfg')
	
	for song in songs:
		var _name:String = Game.format_str(song.song)
		#if !HighScore.saved_scores.has_section_key(_name): pass
		if song.diff_list == JsonHandler.base_diffs:
			HighScore.set_data(_name, HighScore.get_data(_name))
			

		#if best_scores.has_section_key('Song Scores', _name): # if it exists, get it so we dont delete scores
		#	da_data = best_scores.get_value('Song Scores', _name)
		var da_data:Dictionary = {}
		for dif in song.diff_list:
			if da_data.has(dif): continue
		#	HighScore.set_score(_name, dif, HighScore.get_data(_name, dif))
			da_data[dif] = HighScore.get_data(_name, dif)
		
		HighScore.set_data(_name, da_data)
		#best_scores.set_value('Song Scores', _name, da_diffs)
	
	#best_scores.save('user://highscores.cfg') # then save and reload, just to make sure we keep it
	#best_scores.load('user://highscores.cfg')
	
class FreeplaySong extends Alphabet:
	var song:String = 'Tutorial'
	var diff_list:Array = JsonHandler.base_diffs
	var bg_color:Color = Color.WHITE
	var icon:String = 'face'

	func _init(info, diffs:Array = []):
		if diffs.size() > 0:
			diff_list = diffs
		self.song = info[0]
		self.icon = info[1]
		self.bg_color = Color(info[2][0] / 255.0, info[2][1] / 255.0, info[2][2] / 255.0)
		
		is_menu = true
		super(song, true)
