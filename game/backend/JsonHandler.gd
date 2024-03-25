extends Node2D;

var base_diffs:Array[String] = ['easy', 'normal', 'hard']
var check_diff:String
func parse_song(song:String = 'test', type:String = 'psych', diff:String = 'hard'):
	var parsed_song
	check_diff = diff
	match type:
		#'base'    : parsed_song = base(song)
		'psych'   : parsed_song = psych(song)
		#'fps_plus': parsed_song = fps_plus(song)
		#'maru'    : parsed_song = maru(song)
		#'osu'     : parsed_song = osu(song)
		#'': parsed_song = psych(song)
	return parsed_song

#func base(song:String): pass
func psych(song:String):
	var json = you_WILL_get_a_json(song)
	var parsed = JSON.parse_string(json.get_as_text())
	return parsed.song # i dont want to have to do no SONG.song.bpm or something

#func fps_plus(song:String): pass
#func maru(song:String): pass
#func osu(song:String): pass

func you_WILL_get_a_json(song:String):
	var path:String = 'res://assets/songs/'+ song + '/charts'
	var return_file:String = 'test.json'
	#var dir_files = DirAccess.get_files_at(path)

	#if dir_files.has(check_diff):
	return_file = 'hard' #check_diff
	#else:
	#	printerr('COULD NOT FIND JSON: "' + song + '/' + check_diff + '.json"')
		
	return FileAccess.open(path + '/' + return_file + '.json', FileAccess.READ)

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
