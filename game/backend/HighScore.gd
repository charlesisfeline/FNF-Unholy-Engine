extends Node

var song_scores:ConfigFile
const PASSWORD = 'am i am?'
const DEFAULT_LAYOUT = [0, 0, 0, 'N/A', 0] # score, accuracy, misses, FC, highest combo

func _ready() -> void:
	song_scores = ConfigFile.new()
	#var save_check = song_scores.load_encrypted_pass('user://highscores.cfg', PASSWORD)
	#if save_check != OK: # old format and not encrypted, delete and resave
	#	DirAccess.remove_absolute('user://highscores.cfg')
	#	save_and_reload()
	
func get_all_scores() -> void:
	var scores = ConfigFile.new()
	if FileAccess.file_exists('user://highscores.cfg'):
		scores.load('user://highscores.cfg')
	else:
		scores

func get_score(song:String, diff:String):
	return song_scores.get_value(get_section(), diff, 0)

func b(song_list:Array[String], diff:String = 'hard'):
	var total_score:int = 0
	for song in song_list:
		total_score += get_score(song, diff)
			
	return total_score
	
func save_score(song:String, diff:String = 'hard', data:Array = DEFAULT_LAYOUT):
	var sec = get_section()
	if song_scores.has_section_key(sec, song):
		var saved_data = song_scores.get_value(sec, song)
		saved_data[diff] = data
		song_scores.set_value(sec, song, saved_data)
	else:
		add_key(song)
		
	save_and_reload()
	
func save_and_reload():
	song_scores.save_encrypted_pass('user://highscores.cfg', PASSWORD)
	song_scores.load_encrypted_pass('user://highscores.cfg', PASSWORD)
	
func add_key(key:String, diffs:Array = ['easy', 'normal', 'hard']):
	if key.is_empty(): 
		printerr('HighScore: add_key() | Value is empty')
		return
	
	var layout = {}
	for i in diffs:
		layout[i] = DEFAULT_LAYOUT
	song_scores.set_value(get_section(), key, layout)
	
	save_and_reload()
	
func get_section(): return 'Legacy Scores' if Prefs.legacy_score else 'Song Scores'
