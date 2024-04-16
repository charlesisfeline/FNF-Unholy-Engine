extends Node2D;

var base_diffs:Array[String] = ['easy', 'normal', 'hard']
var get_diff:String
var _SONG
func parse_song(song:String, diff:String, type:String = 'psych'):
	var parsed_song
	song = song.to_lower().strip_edges(true, true).replace(' ', '-')
	get_diff = diff
	match type:
		#'base'    : parsed_song = base(song)
		'psych'   : parsed_song = psych(song)
		#'fps_plus': parsed_song = fps_plus(song)
		#'maru'    : parsed_song = maru(song)
		#'osu'     : parsed_song = osu(song)
		#'': parsed_song = psych(song)
	_SONG = parsed_song

#func base(song:String): pass
func psych(song:String):
	var json = you_WILL_get_a_json(song)
	var parsed = JSON.parse_string(json.get_as_text())
	return parsed.song # i dont want to have to do no SONG.song.bpm or something

#func fps_plus(song:String): pass
#func maru(song:String): pass
#func osu(song:String): pass

func you_WILL_get_a_json(song:String):
	var path:String = 'res://assets/songs/%s/charts/' % [song]
	
	if !FileAccess.file_exists(path + get_diff +'.json'):
		printerr(song +' has no '+ get_diff +'.json')
		return you_WILL_get_a_json('tutorial')
	#var dir_files = DirAccess.get_files_at(path)

	#if dir_files.has(get_diff):
	#else:
	#	printerr('COULD NOT FIND JSON: "' + song + '/' + get_diff + '.json"')
		
	return FileAccess.open(path + get_diff +'.json', FileAccess.READ)

func generate_chart(data):
	var chart_notes = []
	for sec in data.notes:
		for note in sec.sectionNotes:
			var time:float = maxf(0, note[0])
			if note[2] is String: continue
			var sustain_length:float = maxf(0, note[2])
			var is_sustain:bool = sustain_length > 0
			var n_data:int = int(note[1])
			var must_hit:bool = sec.mustHitSection if note[1] <= 3 else not sec.mustHitSection
			
			chart_notes.append([time, n_data, is_sustain, sustain_length, must_hit])
			chart_notes.sort()
	return chart_notes

func get_character(character:String = 'bf'):
	var json_path = 'res://assets/data/characters/%s.json' % [character]
	if !FileAccess.file_exists(json_path):
		printerr('JSON: get_character | JSON FILE [%s.json] COULD NOT BE FOUND' % [character]);
		return 'Nothin'
	var file = FileAccess.open(json_path, FileAccess.READ)
	return JSON.parse_string(file.get_as_text())
