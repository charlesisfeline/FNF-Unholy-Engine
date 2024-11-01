extends Node2D;

const base_diffs:Array[String] = ['easy', 'normal', 'hard']
var song_diffs:Array = []
var get_diff:String

var _SONG:Dictionary = {} # change name of this to like SONG_DATA or something
var song_meta:Dictionary = {}
var song_variant:String = '' # (erect, pico mix and whatnot)
var song_root:String = ''

var chart_notes:Array = [] # keep loaded chart and events for restarting songs
var song_events:Array[EventData] = []

var parse_type:String = ''
func parse_song(song:String, diff:String, variant:String = '', type:String = 'psych', auto_create:bool = true):
	_SONG.clear()
	song_root = ''
	song_variant = ''

	if !variant.is_empty(): 
		if variant != 'normal' and !variant.begins_with('-'):
			variant = '-'+ variant
			song_root = Game.format_str(song)
		else:
			variant = ''
	
	song = Game.format_str(song)
	song_variant = variant
	if ResourceLoader.exists('res://assets/songs/'+ song +'/chart'+ song_variant +'.json'):
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
	#if split:
	#	auto_create = false
	#	reform_parts(song)
		
	if parse_type == 'v_slice':
		var meta_path:String = 'res://assets/songs/'+ song +'/metadata'+ song_variant +'.json'
		if ResourceLoader.exists(meta_path):
			song_meta = JSON.parse_string(FileAccess.open(meta_path, FileAccess.READ).get_as_text())
			print('Loaded meta: '+ meta_path)
			_SONG.speed = _SONG.scrollSpeed[diff] if _SONG.scrollSpeed.has(diff) else _SONG.scrollSpeed.default
			_SONG.player1 = song_meta.playData['characters'].player
			_SONG.gfVersion = song_meta.playData['characters'].girlfriend
			_SONG.player2 = song_meta.playData['characters'].opponent
			_SONG.stage = stage_to(song_meta.playData.stage)
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
	if parsed.has('song') and parsed.song is Dictionary:
		parsed = parsed.song
	return parsed # i dont want to have to do no SONG.song.bpm or something

#func fps_plus(song:String): pass
#func maru(song:String): pass
#func osu(song:String): pass

func reform_parts(song:String):
	parse_type = 'psych'
	var in_folder := DirAccess.get_files_at('res://assets/songs/'+ song +'/charts/')
	var to_parse:Array = []
	for i:String in in_folder:
		if i.begins_with('part'):
			to_parse.append(i)
			
	var chart = Chart.new()
	var temp_SONG = {}
	var added_first:bool = false
	for i in to_parse:
		print(i)
		var le_file = FileAccess.open('res://assets/songs/'+ song +'/charts/'+ i, FileAccess.READ).get_as_text()
		var parsed = JSON.parse_string(le_file)
		if !added_first:
			added_first = true
			temp_SONG = parsed.song
		else:
			temp_SONG.notes.append(parsed.song.notes)
		chart_notes.append(chart.load_common(parsed.song))
		
	_SONG = temp_SONG

func you_WILL_get_a_json(song:String) -> FileAccess:
	var path:String = 'res://assets/songs/%s/charts/' % song
	var returned:String
	
	if parse_type == 'v_slice':
		returned = path.replace('charts/', '') +'chart'+ song_variant +'.json'
	else:
		if !ResourceLoader.exists(path + get_diff +'.json'):
			printerr(song +' has no '+ get_diff +'.json')
			get_diff = 'hard'
			return you_WILL_get_a_json('tutorial')
		returned = path + get_diff +'.json'
	#var dir_files = DirAccess.get_files_at(path)

	#if dir_files.has(get_diff):
	#else:
	#	printerr('COULD NOT FIND JSON: "' + song + '/' + get_diff + '.json"')
	print('Loaded json: '+ returned)
	return FileAccess.open(returned, FileAccess.READ)

func stage_to(stage:String):
	match stage.replace('Erect', ''):
		'spookyMansion': return 'spooky'
		'limoRide': return 'limo'
		'phillyTrain': return 'philly'
		'phillyStreets': return 'philly-streets'
		'mallXmas': return 'mall'
		'mallXmasEvil': return 'mall-evil'
		'school': return 'school'
		'schoolEvil': return 'school-evil'
		'tankmanBattlefield': return 'tank'
		_: return 'stage'

func generate_chart(data, keep_loaded:bool = true) -> Array:
	if data == null: 
		return parse_song('tutorial', get_diff)
	
	var chart = Chart.new()
	var _notes := chart.load_chart(data, parse_type, get_diff) # get diff here only matters for base game as of now
	song_events = chart.get_events(data) # load events whenever chart is made

	if keep_loaded:
		chart_notes = _notes.duplicate()
		
	return _notes

func get_character(character:String = 'bf'):
	var json_path = 'res://assets/data/characters/%s.json' % character
	if !ResourceLoader.exists(json_path):
		printerr('JSON: get_character | [%s.json] COULD NOT BE FOUND' % character);
		return null
	var file = FileAccess.open(json_path, FileAccess.READ)
	return JSON.parse_string(file.get_as_text())

func parse_week(week:String = 'week1') -> Dictionary: # in week folder
	week = week.replace('.json', '')
	var week_json = FileAccess.open('res://assets/data/weeks/'+ week.strip_edges() +'.json', FileAccess.READ)
	var json = JSON.parse_string(week_json.get_as_text())
	return json
