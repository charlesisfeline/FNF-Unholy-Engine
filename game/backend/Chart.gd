class_name Chart; extends Node2D;
# makes a chart from a stated json, and sends it to JsonHandler chart_notes and song_events

static var _notes:Array = []
static func load(data, chart_type:String = 'psych', diff:String = 'normal'):
	if data == null: return []
	_notes.clear()
	match chart_type:
		'old_base', 'psych': return load_common(data)
		'base': return load_base(data, diff)

# old base game/psych
static func load_common(data):
	for sec in data.notes:
		for note in sec.sectionNotes:
			var time:float = maxf(0, note[0])
			if note[2] is String: continue
			var sustain_length:float = maxf(0, note[2])
			var is_sustain:bool = sustain_length > 0
			var n_data:int = int(note[1])
			var must_hit:bool = sec.mustHitSection if note[1] <= 3 else not sec.mustHitSection
			var type:String = str(note[3]) if note.size() > 3 else ''
			if type == 'true': type = 'alt'
			
			var to_add = [round(time), n_data, is_sustain, sustain_length, must_hit, type]
			if !_notes.has(to_add): # skip adding a note that exists
				_notes.append(to_add)
			_notes.sort_custom(func(a, b): return a[0] < b[0])
			
	return _notes

static func load_base(data, diff:String = 'normal'):
	#print(data.notes['normal'])
	for note in data.notes[diff]:
		var time:float = maxf(0, note.t)
		var sustain_length:float = maxf(0, note.l) if note.has('l') else 0
		var type:String = str(note.k) if note.has('k') else ''
		if type == 'true': type = 'alt'
			
		var to_add = [round(time), int(note.d), sustain_length > 0, sustain_length, note.d <= 3, type]
		if !_notes.has(to_add): # skip adding a note that exists
			_notes.append(to_add)
		_notes.sort_custom(func(a, b): return a[0] < b[0])
	
	return _notes

func get_events(song:String = ''):
	var path_to_check = 'res://assets/songs/%s/events.json' % [song]
	var events_found:Array = []
	var events:Array[EventNote] = []
	if JsonHandler._SONG.has('events'): # check current song json for any events
		events_found.append_array(JsonHandler._SONG.events)
	
	if FileAccess.file_exists(path_to_check): # then check if there is a event json
		print(path_to_check)
		var json = JSON.parse_string(FileAccess.open(path_to_check, FileAccess.READ).get_as_text()).song
		if json.has('notes') and json.notes.size() > 0: # if events are a -1 note
			for sec in json.notes:
				for note in sec.sectionNotes:
					if note[1] == -1: 
						events_found.append([note[0], [[note[2], note[3], note[4]]]])
		else:
			events_found.append_array(json.events)
	
	for event in events_found:
		var time = event[0]
		for i in event[1]:
			var new_event = EventNote.new([time, i])
			events.append(new_event)
			#print([time, i])
	
	events.sort_custom(func(a, b): return a.strum_time < b.strum_time)
	return events
