extends Node2D

@onready var cam:Camera2D = $Camera
@onready var ui:UI = $UI
@onready var other:CanvasLayer = $OtherUI # like psych cam other, above ui, and unaffected by ui zoom

@onready var Judge:Rating = Rating.new()

var default_zoom:float = 0.8
var SONG
var cur_style:String = 'default': # yes
	set(new_style): 
		ui.cur_style = new_style
		cur_style = ui.cur_style
var cur_speed:float = 1:
	set(new_speed):
		cur_speed = new_speed
		for note in notes: note.speed = cur_speed

var chart_notes
var notes:Array[Note] = []
var events:Array[EventNote] = []
var start_time:float = 0 # when the first note is actually loaded
var spawn_time:int = 2000

var player_strums:Array[Strum] = []
var opponent_strums:Array[Strum] = []

var key_names = ['note_left', 'note_down', 'note_up', 'note_right']

var should_save:bool = !Prefs.auto_play
@onready var auto_play:bool:
	set(auto):
		if auto: should_save = false
		auto_play = auto
		ui.player_group.is_cpu = auto_play

var can_gain_score:bool = true
var score:int = 0
var combo:int = 0
var misses:int = 0

func _ready():
	ui.health_bar.scale = Vector2(0.8, 0.8)
	
	auto_play = Prefs.auto_play # there is a reason
	
	SONG = JsonHandler._SONG

	Conductor.load_song(SONG.song)
	Conductor.bpm = SONG.bpm
	Conductor.paused = false
	cur_speed = SONG.speed
	
	var chars = [JsonHandler.get_character(SONG.player1), JsonHandler.get_character(SONG.player2)]
	ui.icon_p1.change_icon(chars[0].healthicon if chars[0] != null else 'face', true)
	ui.icon_p2.change_icon(chars[1].healthicon if chars[1] != null else 'face')
	
	if SONG.has('stage') and SONG.stage.contains('school'):
		cur_style = 'pixel'
		
	if Prefs.rating_cam == 'game':
		Judge.rating_pos = cam.position + Vector2(-15, -15)
		Judge.combo_pos = cam.position + Vector2(-150, 60)
	elif Prefs.rating_cam == 'hud':
		Judge.rating_pos = Vector2(580, 300)
		Judge.combo_pos = Vector2(450, 400)
		
	Discord.change_presence('Starting '+ SONG.song.capitalize())
	
	if !JsonHandler.chart_notes.is_empty():
		chart_notes = JsonHandler.chart_notes.duplicate()
	else:
		chart_notes = JsonHandler.generate_chart(SONG)
		
	start_time = chart_notes[0][0]
	events = JsonHandler.song_events.duplicate()
	
	ui.start_countdown(true)
	section_hit(0) #just for 1st section stuff

var section_data
var chunk:int = 0
func _process(delta):
	if Input.is_key_pressed(KEY_R): ui.hp = 0
	if ui.hp <= 0:
		can_gain_score = false
		
	if Input.is_action_just_pressed("debug_1"):
		await RenderingServer.frame_post_draw
		Game.switch_scene('debug/Charting_Scene')
	if Input.is_action_just_pressed("back"):
		auto_play = !auto_play
	if Input.is_action_just_pressed("accept"):
		Conductor.resync_audio()
		get_tree().paused = true
		other.add_child(load('res://game/scenes/pause_screen.tscn').instantiate())
	
	if ui.finished_countdown:
		Discord.change_presence('Playing '+ SONG.song.capitalize() +' - '+ JsonHandler.get_diff.to_upper(),\
		 Game.to_time(Conductor.song_pos) +' / '+ Game.to_time(Conductor.song_length) +' | '+ \
		  str(round(abs(Conductor.song_pos / Conductor.song_length) * 100.0)) +'% Complete')
		
	ui.icon_p1.position.y = 0 
	ui.icon_p2.position.y = 0 
	
	if chart_notes != null:
		while chart_notes.size() > 0 and chunk != chart_notes.size() and chart_notes[chunk][0] - Conductor.song_pos < spawn_time / cur_speed:
			if chart_notes[chunk][0] - Conductor.song_pos > spawn_time / cur_speed:
				break
			
			var note_info = NoteData.new(chart_notes[chunk])
			var new_note:Note = Note.new(note_info)
			new_note.speed = cur_speed
			notes.append(new_note)

			if chart_notes[chunk][2]: # if it has a sustain
				var new_sustain:Note = Note.new(new_note, true)
				new_sustain.speed = new_note.speed
		
				notes.append(new_sustain)
				ui.add_to_strum_group(new_sustain, new_sustain.must_press)

			ui.add_to_strum_group(new_note, new_note.must_press)
			notes.sort_custom(func(a, b): return a.strum_time < b.strum_time)
			chunk += 1

	if notes.size() != 0:
		for note in notes:
			if note.spawned:
				note.follow_song_pos(ui.player_strums[note.dir] if note.must_press else ui.opponent_strums[note.dir])
				if note.is_sustain:
					if note.must_press:
						if note.can_hit and note.should_hit and !note.was_good_hit:
							#var check = (auto_play or Input.is_action_pressed(key_names[note.dir]))
							note.holding = (auto_play or Input.is_action_pressed(key_names[note.dir]))
							good_sustain_press(note, delta)
						if !auto_play and note.strum_time < Conductor.song_pos - (300 / note.speed) \
							and !note.holding: note_miss(note)
					else:
						if note.can_hit and !note.was_good_hit:
							opponent_sustain_press(note)
					
					if note.temp_len <= 0: kill_note(note)

				else:
					if note.must_press:
						if auto_play and note.strum_time <= Conductor.song_pos and note.should_hit:
							good_note_hit(note)
						if !auto_play and note.strum_time < Conductor.song_pos - (300 / note.speed) and !note.was_good_hit:
							note_miss(note)
					else:
						if note.was_good_hit:
							opponent_note_hit(note)
	if events.size() != 0:
		for event in events:
			if event.strum_time <= Conductor.song_pos:
				event_hit(event)
				events.remove_at(0)

func beat_hit(beat) -> void:
	ui.icon_p1.bump()
	ui.icon_p2.bump()

func section_hit(section) -> void:
	if JsonHandler.parse_type != 'base' and SONG.notes.size() > section:
		section_data = SONG.notes[section]

		if section_data.has('changeBPM') and section_data.has('bpm'):
			if section_data.changeBPM and Conductor.bpm != section_data.bpm:
				Conductor.bpm = section_data.bpm
				print('Changed BPM: ' + str(section_data.bpm))

func _unhandled_key_input(_event) -> void:
	if auto_play: return
	for i in 4:
		if Input.is_action_just_pressed(key_names[i]): key_press(i)
		if Input.is_action_just_released(key_names[i]): key_release(i)

func key_press(key:int = 0) -> void:
	var hittable_notes:Array[Note] = notes.filter(func(i:Note):
		return i.dir == key and i.spawned and !i.is_sustain and i.must_press and i.can_hit and !i.was_good_hit
	)
	hittable_notes.sort_custom(func(a, b): return a.strum_time < b.strum_time)
	
	if hittable_notes.size() != 0:
		var note:Note = hittable_notes[0]
			
		if hittable_notes.size() > 1: # mmm idk anymore
			for funny in hittable_notes: # temp dupe note thing killer bwargh i hate it
				if note == funny: continue 
				if absf(funny.strum_time - note.strum_time) < 1.0:
					kill_note(funny)
					
		good_note_hit(note)

	var strum = ui.player_strums[key]
	if !strum.animation.contains('confirm') and !strum.animation.contains('press'):
		strum.play_anim('press')
		strum.reset_timer = 0

func key_release(key:int = 0) -> void:
	ui.player_strums[key].play_anim('static')

func try_death() -> void:
	for item in ['combo', 'score', 'misses']: set(item, 0)
	ui.reset_count()
	refresh()

func song_end() -> void:
	if should_save:
		var scores = ConfigFile.new()
		scores.load('user://highscores.cfg')
		var to_save = scores.get_value('Song Scores', Game.format_str(SONG.song))
		if to_save[JsonHandler.get_diff] == [0, 0, 'N/A'] or score > to_save[JsonHandler.get_diff][0]: 
			to_save[JsonHandler.get_diff] = [score, ui.accuracy, ui.fc]

			scores.set_value('Song Scores', Game.format_str(SONG.song), to_save)
			scores.save('user://highscores.cfg')
		
	#refresh(false)
	Conductor.reset()
	Game.switch_scene("menus/freeplay")
	
func refresh(restart:bool = true) -> void: # start song from beginning with no restarts
	Conductor.reset_beats()
	Conductor.bpm = SONG.bpm # reset bpm to init whoops
	can_gain_score = true
	
	while notes.size() != 0:
		kill_note(notes[0])
	notes.clear()
	events.clear()
	chart_notes = JsonHandler.chart_notes.duplicate()
	events = JsonHandler.song_events.duplicate()
	chunk = 0
	if restart:
		Discord.change_presence('Starting: '+ SONG.song.capitalize())
		ui.get_node('Text').text = '0:00'
		ui.time_bar.value = 0
		Conductor.song_pos = (-Conductor.crochet * 4)
		ui.start_countdown(true)
		ui.hp = 50
	else:
		Conductor.start(0)
	section_hit(0)

func event_hit(event:EventNote) -> void:
	print(event.event, event.values)
	match event.event:
		'Change Scroll Speed': 
			var new_speed = SONG.speed * float(event.values[0])
			var len := float(event.values[1])
			if len > 0:
				create_tween().tween_property(Game.scene, 'cur_speed', new_speed, len)
			else:
				cur_speed = new_speed

func good_note_hit(note:Note) -> void:
	if note.type.length() > 0: print(note.type, ' bf')

	if Conductor.vocals.stream != null: 
		Conductor.vocals.volume_db = linear_to_db(1)
		
	ui.player_group.note_hit(note)
	grace = true
	combo += 1
	
	var time = Conductor.song_pos - note.strum_time if !auto_play else 0
	var hit_rating = Judge.get_rating(time)
	var judge_info = Judge.get_score(hit_rating)
	pop_up_combo(hit_rating, combo)
	if can_gain_score:
		score += int(300 * (((1.0 + exp(-0.08 * (abs(time) - 40))) + 54.99)) / (55 / judge_info[2])) # good enough im happy
		ui.note_percent += judge_info[1]
		ui.total_hit += 1
		ui.hit_count[hit_rating] += 1
	ui.hp += 2.3
	
	if Prefs.note_splashes != 'none':
		if Prefs.note_splashes == 'all' or (Prefs.note_splashes == 'sicks' and hit_rating == 'sick'):
			ui.spawn_splash(ui.player_strums[note.dir])
			
	ui.update_score_txt()
	kill_note(note)
	if Prefs.hitsound_volume != 0:
		Audio.play_sound('hitsound', Prefs.hitsound_volume / 100.0)

var time_dropped:float = 0
func good_sustain_press(sustain:Note, delt:float = 0.0) -> void:
	if !auto_play and Input.is_action_just_released(key_names[sustain.dir]) and !sustain.was_good_hit:
		#sustain.dropped = true
		sustain.holding = false
		print('let go too soon ', sustain.length)
		time_dropped += delt
		note_miss(sustain)
		return
	
	if sustain.holding:
		if Conductor.vocals.stream != null: 
			Conductor.vocals.volume_db = linear_to_db(1) 
		ui.player_group.note_hit(sustain)
		
		grace = true
		if can_gain_score:
			score += floor(550 * delt)
		ui.hp += (4 * delt)
		ui.update_score_txt()

func opponent_note_hit(note:Note) -> void:
	if note.type.length() > 0: print(note.type, ' dad')

	if section_data != null and section_data.has('altAnim') and section_data.altAnim:
		note.alt = '-alt'
		
	if Conductor.vocals.stream != null:
		var v = Conductor.vocals_opp if Conductor.mult_vocals else Conductor.vocals
		v.volume_db = linear_to_db(1)
	ui.opponent_group.note_hit(note)
	kill_note(note)

func opponent_sustain_press(sustain:Note) -> void:
	if Conductor.vocals.stream != null:
		var v = Conductor.vocals_opp if Conductor.mult_vocals else Conductor.vocals
		v.volume_db = linear_to_db(1)
		
	if section_data != null and section_data.has('altAnim') and section_data.altAnim:
		sustain.alt = '-alt'
	ui.opponent_group.note_hit(sustain)

var grace:bool = true
func note_miss(note:Note) -> void:
	if note.should_hit:
		ui.player_group.note_miss(note)
		misses += 1
		if can_gain_score:
			ui.hit_count['miss'] = misses
			score -= floor(note.length * 2) if note.is_sustain else int(30 + (15 * floor(misses / 3)))
			ui.total_hit += 1
		
		var hp_diff = ((note.length / 30) if note.is_sustain else 4.7)
		if note.is_sustain and grace and ui.hp - hp_diff <= 0: # big ass sustains wont kill you instantly
			grace = false
			hp_diff = ui.hp - 0.1
			
		ui.hp -= hp_diff 
	
		if combo >= 5: pop_up_combo('', '000', true)
		combo = 0
	
		if Conductor.vocals != null:
			Conductor.vocals.volume_db = linear_to_db(0)
		ui.update_score_txt()
	kill_note(note)
	
func pop_up_combo(rating:String = 'sick', combo = -1, is_miss:bool = false) -> void:
	if Prefs.rating_cam != 'none':
		var cam:Callable = ui.add_behind if Prefs.rating_cam == 'hud' else add_child
	
		if rating.length() != 0:
			var new_rating = Judge.make_rating(rating)
			cam.call(new_rating)
	
			if new_rating != null: # opening chart editor at the wrong time would fuck it	
				var r_tween = create_tween()
				r_tween.tween_property(new_rating, "modulate:a", 0, 0.2).set_delay(Conductor.crochet * 0.001)
				r_tween.finished.connect(new_rating.queue_free)
		
		if (combo is int and combo > -1) or (combo is String and combo.length() > 0):
			for num in Judge.make_combo(combo):
				cam.call(num)
				
				if num != null:
					var n_tween = create_tween()
					if is_miss: num.modulate = Color.DARK_RED
					n_tween.tween_property(num, "modulate:a", 0, 0.2).set_delay(Conductor.crochet * 0.002)
					n_tween.finished.connect(num.queue_free)
	
func kill_note(note:Note) -> void:
	if note != null:
		note.spawned = false
		notes.remove_at(notes.find(note))
		note.queue_free()
