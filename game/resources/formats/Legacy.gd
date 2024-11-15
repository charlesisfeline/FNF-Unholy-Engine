class_name Legacy; extends Chart

var p_v1:bool = false
func _init(s:bool = false): p_v1 = s

func parse_chart(data) -> Array:
	print(format)
	for sec in data.notes:
		for note in sec.sectionNotes:
			if note[1] < 0: continue
			var time:float = maxf(0, note[0])
			
			if note[2] is String: continue
			var sustain_len:float = maxf(0, note[2])
			var is_sustain:bool = sustain_len > 0
			
			var n_data:int = int(note[1])
			var must_hit:bool = sec.mustHitSection if note[1] <= 3 else not sec.mustHitSection
			if p_v1: must_hit = n_data < 4
				
			var n_type:String = str(note[3]) if note.size() > 3 else ''
			if n_type == 'true': n_type = 'Alt'
			
			add_note([round(time), n_data, is_sustain, sustain_len, must_hit, n_type])
	
	return_notes.sort_custom(func(a, b): return a[0] < b[0])
	return return_notes
