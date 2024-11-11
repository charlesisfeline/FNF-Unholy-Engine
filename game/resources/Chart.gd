class_name Chart; extends Resource;
# makes a chart from a json

enum FORMAT {
	LEGACY, # old base game, old psych
	V_SLICE, 
	PSYCH_V1#, 
	# vv unfinished vv
	#FPS_PLUS = 3, 
	#MARU = 4
}
var format:FORMAT

var return_notes:Array = []
func load_chart(data, chart_type:String = 'psych', diff:String = 'normal') -> Array:
	if data == null: return []
	return_notes.clear()
	format = get_format(chart_type)
	match format:
		FORMAT.LEGACY, FORMAT.PSYCH_V1: 
			return load_common(data)
		FORMAT.V_SLICE: 
			return load_slice(data, diff)
		_: return []
		
# for loading a chart that isnt named a difficulty
# used for pico speaker
func load_named_chart(song_name:String, chart_name:String = ''):
	var path:String = 'res://assets/songs/%s/charts/%s.json' % [Game.format_str(song_name), chart_name]
	print(path)
	if ResourceLoader.exists(path, 'JSON'):
		var json = JSON.parse_string(FileAccess.open(path, FileAccess.READ).get_as_text())
		return load_chart(json.song)
	return []
	
# old base game/psych
func load_common(data) -> Array:
	for sec in data.notes:
		for note in sec.sectionNotes:
			if note[1] < 0: continue
			var time:float = maxf(0, note[0])
			
			if note[2] is String: continue
			var sustain_length:float = maxf(0, note[2])
			var is_sustain:bool = sustain_length > 0
			
			var n_data:int = int(note[1])
			var must_hit:bool = sec.mustHitSection if note[1] <= 3 else not sec.mustHitSection
			if format == FORMAT.PSYCH_V1: must_hit = n_data < 4; print('hi')
			
			var n_type:String = str(note[3]) if note.size() > 3 else ''
			if n_type == 'true': n_type = 'Alt'
			
			var to_add = [round(time), n_data, is_sustain, sustain_length, must_hit, n_type]
			if !return_notes.has(to_add): # skip adding a note that exists
				return_notes.append(to_add)
	
	return_notes.sort_custom(func(a, b): return a[0] < b[0])
	return return_notes

# new base game
func load_slice(data, diff:String = 'normal') -> Array:
	#print(data.notes['normal'])
	for note in data.notes[diff]:
		var time:float = maxf(0, note.t)
		var sustain_length:float = maxf(0.0, note.l) if note.has('l') else 0.0
		var n_type:String = str(note.k) if note.has('k') else ''
		if n_type == 'true': n_type = 'alt'
			
		var to_add = [round(time), int(note.d), sustain_length > 0, sustain_length, note.d <= 3, n_type]
		if !return_notes.has(to_add): # skip adding a note that exists
			return_notes.append(to_add)
	
	return_notes.sort_custom(func(a, b): return a[0] < b[0])
	return return_notes

func get_events(SONG:Dictionary) -> Array[EventData]:
	var path_to_check = 'res://assets/songs/%s/events.json' % Game.format_str(SONG.song)
	#if parse_type == 'v_slice': path_to_check.replace('events', 'charts/chart')
	var events_found:Array = []
	var events:Array[EventData] = []
	if SONG.has('events'): # check current song json for any events
		events_found.append_array(SONG.events)
	
	
	if format != FORMAT.V_SLICE and ResourceLoader.exists(path_to_check, 'JSON'): # then check if there is a event json
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
		if format == FORMAT.V_SLICE:
			events.append(EventData.new(event, 'v_slice'))
		else:
			for i in event[1]:
				events.append(EventData.new([event[0], i]))
	
	events.sort_custom(func(a, b): return a.strum_time < b.strum_time)
	return events

func get_format(f:String) -> FORMAT:
	var e:FORMAT = FORMAT.LEGACY
	match f.to_lower().strip_edges():
		'psych', 'base', 'legacy': e = FORMAT.LEGACY
		'v_slice': e = FORMAT.V_SLICE
		'psych_v1': e = FORMAT.PSYCH_V1
		#'fps_plus': e = FORMAT.FPS_PLUS
		#'maru': e = FORMAT.MARU
	return e
