extends Node2D;

signal notes_loaded
signal loaded

var base_diffs:Array[String] = ['easy', 'normal', 'hard']
var song_diffs:Array = []
var get_diff:String

var charted:bool = false
var _SONG = null

var chart_notes:Array = [] # keep loaded chart and events for restarting songs
var song_events:Array[EventData] = []
var old_notes:Array = []
var old_events:Array[EventData] = []

var song_meta = null
var parse_type:String = ''
func parse_song(song:String, diff:String, auto_create:bool = false, type:String = 'psych'):
	if _SONG != null: _SONG.clear()
	
	song = Game.format_str(song)
	if FileAccess.file_exists('res://assets/songs/'+ song +'/charts/chart.json'):#\
		#FileAccess.file_exists('res://assets/songs/'+ song +'/metadata.json')
		type = 'v_slice'
	
	var parsed_song
	get_diff = diff.to_lower()
	match type:
		'v_slice' : parsed_song = v_slice(song)
		'psych'   : parsed_song = psych(song)
		#'fps_plus': parsed_song = fps_plus(song)
		#'maru'    : parsed_song = maru(song)
		#'osu'     : parsed_song = osu(song)
		#_: parsed_song = psych(song)
	_SONG = parsed_song
	
	if FileAccess.file_exists('res://assets/songs/'+ song +'/metadata.json'):
		song_meta = JSON.parse_string(FileAccess.open('res://assets/songs/'+ song +'/metadata.json', FileAccess.READ).get_as_text())
		print(song_meta)
		if type == 'v_slice':
			_SONG.speed = _SONG.scrollSpeed[diff] if _SONG.scrollSpeed.has(diff) else _SONG.scrollSpeed.default
			var play = song_meta.playData
			_SONG.player1 = play['characters'].player
			_SONG.gfVersion = play['characters'].girlfriend
			_SONG.player2 = play['characters'].opponent
			_SONG.stage = play.stage
			_SONG.song = song_meta.songName
			_SONG.bpm = song_meta.timeChanges[0].bpm
			
	if auto_create:
		generate_chart(_SONG)
		#var thread = Thread.new()
		#thread.start(generate_chart.bind(_SONG))
		#await thread.wait_to_finish()

func v_slice(song:String) -> Dictionary:
	parse_type = 'v_slice'
	var json = you_WILL_get_a_json(song) #FileAccess.open('res://assets/songs/'+ song +'/charts/chart.json', FileAccess.READ).get_as_text()
	return JSON.parse_string(json.get_as_text())
	
func psych(song:String) -> Dictionary:
	parse_type = 'psych'
	var json = you_WILL_get_a_json(song)
	var parsed = JSON.parse_string(json.get_as_text())
	return parsed.song # i dont want to have to do no SONG.song.bpm or something

#func fps_plus(song:String): pass
#func maru(song:String): pass
#func osu(song:String): pass

func you_WILL_get_a_json(song:String) -> FileAccess:
	var path:String = 'res://assets/songs/%s/charts/' % song
	var returned:String
	
	if parse_type == 'v_slice':
		returned = path + 'chart.json'
	else:
		if !FileAccess.file_exists(path + get_diff +'.json'):
			printerr(song +' has no '+ get_diff +'.json')
			get_diff = 'hard'
			return you_WILL_get_a_json('tutorial')
		returned = path + get_diff +'.json'
	#var dir_files = DirAccess.get_files_at(path)

	#if dir_files.has(get_diff):
	#else:
	#	printerr('COULD NOT FIND JSON: "' + song + '/' + get_diff + '.json"')
	print(returned)
	return FileAccess.open(returned, FileAccess.READ)

func generate_chart(data, keep_loaded:bool = true) -> Array: # idea, split chart into parts, then load each seperately
	if data == null: 
		return parse_song('tutorial', get_diff)
	
	var chart = Chart.new()

	#if parse_type != 'v_slice':
	song_events = get_events(Game.format_str(data.song)) # load events whenever chart is made
	
	var _notes := chart.load_chart(data, parse_type, get_diff) # get diff here only matters for base game as of now
	if keep_loaded:
		chart_notes = _notes.duplicate()
		
	return _notes

func get_events(song:String = '') -> Array[EventData]:
	var path_to_check = 'res://assets/songs/%s/events.json' % song
	#if parse_type == 'v_slice': path_to_check.replace('events', 'charts/chart')
	var events_found:Array = []
	var events:Array[EventData] = []
	if _SONG.has('events'): # check current song json for any events
		events_found.append_array(_SONG.events)
	
	if parse_type != 'v_slice' and FileAccess.file_exists(path_to_check): # then check if there is a event json
		print(path_to_check)
		
		var json = JSON.parse_string(FileAccess.open(path_to_check, FileAccess.READ).get_as_text())
		if json.has('song'): json = json.song
		#if json.has('events'): json = json.events
		
		if json.has('notes') and json.notes.size() > 0: # if events are a -1 note
			for sec in json.notes:
				for note in sec.sectionNotes:
					if note[1] == -1: 
						events_found.append([note[0], [[note[2], note[3], note[4]]]])
		else:
			events_found.append_array(json.events)
	
	for event in events_found:
		if parse_type != 'v_slice':
			for i in event[1]:
				events.append(EventData.new([event[0], i]))
		else:
			events.append(EventData.new(event, 'v_slice'))
	
	events.sort_custom(func(a, b): return a.strum_time < b.strum_time)
	return events

func get_character(character:String = 'bf'):
	var json_path = 'res://assets/data/characters/%s.json' % character
	if !FileAccess.file_exists(json_path):
		printerr('JSON: get_character | [%s.json] COULD NOT BE FOUND' % character);
		return null
	var file = FileAccess.open(json_path, FileAccess.READ)
	return JSON.parse_string(file.get_as_text())

func parse_week(week:String = 'week1') -> Dictionary: # in week folder
	week = week.replace('.json', '')
	var week_json = FileAccess.open('res://assets/data/weeks/'+ week.strip_edges() +'.json', FileAccess.READ)
	var json = JSON.parse_string(week_json.get_as_text())
	return json
