class_name Chart; extends Node2D;
# makes a chart from a json

var return_notes:Array = []
func load_chart(data, chart_type:String = 'psych', diff:String = 'normal'):
	if data == null: return []
	return_notes.clear()
	match chart_type:
		'old_base', 'psych': return load_common(data)
		'base': return load_base(data, diff)
		
# for loading a chart that isnt named a difficulty
# used for pico speaker
func load_named_chart(song_name:String, chart_name:String = ''):
	var path:String = 'res://assets/songs/%s/charts/%s' % [Game.format_str(song_name), chart_name]
	print(path)
	if FileAccess.file_exists(path +'.json'):
		var json = JSON.parse_string(FileAccess.open(path +'.json', FileAccess.READ).get_as_text())
		return load_chart(json.song)
	return
	
# old base game/psych
func load_common(data) -> Array:
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
			if !return_notes.has(to_add): # skip adding a note that exists
				return_notes.append(to_add)
			return_notes.sort_custom(func(a, b): return a[0] < b[0])
			
	return return_notes

# new base game
func load_base(data, diff:String = 'normal') -> Array:
	#print(data.notes['normal'])
	for note in data.notes[diff]:
		var time:float = maxf(0, note.t)
		var sustain_length:float = maxf(0, note.l) if note.has('l') else 0
		var type:String = str(note.k) if note.has('k') else ''
		if type == 'true': type = 'alt'
			
		var to_add = [round(time), int(note.d), sustain_length > 0, sustain_length, note.d <= 3, type]
		if !return_notes.has(to_add): # skip adding a note that exists
			return_notes.append(to_add)
		return_notes.sort_custom(func(a, b): return a[0] < b[0])
	
	return return_notes

func get_events(song:String = '') -> Array[EventNote]:
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
