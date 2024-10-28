class_name Chart; extends Resource;
# makes a chart from a json

enum CHART_TYPE {
	LEGACY, # old base game, old psych
	V_SLICE,
	PSYCH_V1,
	FPS_PLUS,
	MARU
}
var type:CHART_TYPE

var return_notes:Array = []
func load_chart(data, chart_type:String = 'psych', diff:String = 'normal') -> Array:
	if data == null: return []
	return_notes.clear()
	match chart_type:
		'old_base', 'psych': 
			type = CHART_TYPE.LEGACY
			return load_common(data)
		'v_slice': 
			type = CHART_TYPE.V_SLICE
			return load_base(data, diff)
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
var total:int = 0
var cur:int = -1

var cur_notes:int = 0
var total_notes:int = 0

func load_common(data) -> Array:
	#total = data.notes.size() - 1
	for sec in data.notes:
		#cur += 1
		#print(str(cur) +' / '+ str(total))
		total_notes = sec.sectionNotes.size() - 1
		for note in sec.sectionNotes:
			#cur_notes += 1
			#print(str(cur_notes) +' / '+ str(total_notes))
			if note[1] < 0: continue
			var time:float = maxf(0, note[0])
			if note[2] is String: continue
			var sustain_length:float = maxf(0, note[2])
			var is_sustain:bool = sustain_length > 0
			var n_data:int = int(note[1])
			var must_hit:bool = sec.mustHitSection if note[1] <= 3 else not sec.mustHitSection
			var type:String = str(note[3]) if note.size() > 3 else ''
			if type == 'true': type = 'Alt'
			
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
		var sustain_length:float = maxf(0.0, note.l) if note.has('l') else 0.0
		var type:String = str(note.k) if note.has('k') else ''
		if type == 'true': type = 'alt'
			
		var to_add = [round(time), int(note.d), sustain_length > 0, sustain_length, note.d <= 3, type]
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
	
	
	if type != CHART_TYPE.V_SLICE and ResourceLoader.exists(path_to_check, 'JSON'): # then check if there is a event json
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
		if type == CHART_TYPE.V_SLICE:
			events.append(EventData.new(event, 'v_slice'))
		else:
			for i in event[1]:
				events.append(EventData.new([event[0], i]))
	
	events.sort_custom(func(a, b): return a.strum_time < b.strum_time)
	return events
