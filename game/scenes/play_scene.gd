extends Node2D

@onready var camGAME = CanvasGroup.new()
@onready var camNotes = CanvasGroup.new()
@onready var ui:UI = $UI
@onready var cam = $Camera

@onready var Judge:Rating = Rating.new()

var default_zoom:float = 0.8
var SONG
var cur_speed:float = 1:
	set(new_speed):
		cur_speed = new_speed
		for note in notes: note.speed = cur_speed
var cur_stage:String = 'stage'
var stage:StageBase

var chart_notes
var notes:Array[Note] = []
var events:Array[EventNote] = []
var start_time:float = 0 # when the first note is actually loaded
var spawn_time:int = 2000

var boyfriend:Character
var dad:Character
var gf:Character
var characters:Array = []

var player_strums:Array[Strum] = []
var opponent_strums:Array[Strum] = []

var key_names = ['note_left', 'note_down', 'note_up', 'note_right']

@onready var auto_play:bool = Prefs.auto_play

var score:int = 0
var combo:int = 0
var misses:int = 0

func _ready():
	SONG = JsonHandler._SONG
	Conductor.load_song(SONG.song)
	cur_speed = SONG.speed
	if SONG.has('stage'):
		cur_stage = SONG.stage.to_lower().replace(' ', '-')
	else:
		var song = SONG.song.to_lower().replace(' ', '-')
		match song: # daily reminder to kiss daniel
			'spookeez', 'south', 'monster': cur_stage = 'spooky'
			'pico', 'philly-nice', 'blammed': cur_stage = 'philly'
			'satin-panties', 'high', 'milf': cur_stage = 'limo'
			'cocoa', 'eggnog': cur_stage = 'mall'
			'winter-horrorland': cur_stage = 'mall-evil'
			'senpai', 'roses': cur_stage = 'school'
			'thorns': cur_stage = 'school-evil'
			'ugh', 'guns', 'stress': cur_stage = 'tank'
			
	Conductor.bpm = SONG.bpm
	
	var to_load = 'stage'
	if FileAccess.file_exists('res://game/scenes/stages/'+ cur_stage +'.tscn'):
		to_load = cur_stage
		
	stage = load('res://game/scenes/stages/%s.tscn' % [to_load]).instantiate() # im sick of grey bg FUCK
	add_child(stage)
	default_zoom = stage.default_zoom
	#ui.cur_style = 'pixel'
	
	var gf_ver = 'gf'
	if SONG.has('gfVersion'): 
		gf_ver = SONG.gfVersion
	elif SONG.has('player3'): 
		gf_ver = SONG.player3 if SONG.player3 != null else 'gf'
	else: # base game type shit baybeee
		match SONG.song.to_lower().replace(' ', '-'):
			'satin-panties', 'high', 'milf': gf_ver = 'gf-car'
			'cocoa', 'eggnog', 'winter-horrorland': gf_ver = 'gf-christmas'
			'senpai', 'roses', 'thorns': gf_ver = 'gf-pixel'
			'ugh', 'guns': gf_ver = 'gf-tankmen'
			'stress': gf_ver = 'pico-speaker'
		
	print(gf_ver)
	gf = Character.new(stage.gf_pos, gf_ver)
	add_child(gf)
	
	dad = Character.new(stage.dad_pos, SONG.player2)
	add_child(dad)
	
	boyfriend = Character.new(stage.bf_pos, SONG.player1, true)
	add_child(boyfriend)
	
	ui.icon_p1.change_icon(boyfriend.icon, true)
	ui.icon_p2.change_icon(dad.icon)
	
	characters = [boyfriend, dad, gf]
	
	if cur_stage.contains('school'):
		ui.cur_style = 'pixel'
		
	if Prefs.rating_cam == 'game':
		Judge.rating_pos = boyfriend.position + Vector2(-15, -15)
		Judge.combo_pos = boyfriend.position + Vector2(-150, 60)
	elif Prefs.rating_cam == 'hud':
		Judge.rating_pos = Vector2(580, 300)
		Judge.combo_pos = Vector2(450, 400)
		
	print(SONG.song)
	
	Discord.change_presence('Playing '+ SONG.song.capitalize())
	
	#SONG.speed = 10
	#var thread = Thread.new()
	#thread.start(JsonHandler.generate_chart.bind(SONG)) 
	# since im doing something different, this thread will need to be changed
	if JsonHandler.chart_notes.size() > 0:
		chart_notes = JsonHandler.chart_notes
		print('already loaded')
	else:
		chart_notes = JsonHandler.generate_chart(SONG)
		print('made chart')
		
	start_time = chart_notes[0][0]
	events = JsonHandler.song_events
	ui.add_child(camNotes)
	
	#ui = UI.new()
	#camHUD.add_child(ui)
	#await thread.wait_to_finish()
	ui.start_countdown(true)

	section_hit(0)

var cur_section:int = -1
var section_data

var bleh:int = 0
var last_note:Note
func _process(delta):
	if Input.is_action_just_pressed("back"):
		auto_play = !auto_play
	if Input.is_action_just_pressed("accept"): # lol
		get_tree().paused = true
		var pause = load('res://game/scenes/pause_screen.tscn').instantiate()
		ui.add_child(pause)
	
	ui.zoom = lerpf(ui.zoom, 1, delta * 4)
	cam.zoom.x = lerpf(cam.zoom.x, default_zoom, delta * 4)
	cam.zoom.y = cam.zoom.x
	
	if chart_notes != null:
		while chart_notes.size() > 0 and bleh != chart_notes.size() and chart_notes[bleh][0] - Conductor.song_pos < spawn_time / SONG.speed:
			if chart_notes[bleh][0] - Conductor.song_pos > spawn_time / SONG.speed:
				break
			
			var note_info = NoteData.new(chart_notes[bleh])
			var new_note:Note = Note.new(note_info)
			new_note.speed = cur_speed

			notes.append(new_note)

			if chart_notes[bleh][2]: # if it has a sustain
				var new_sustain:Note = Note.new(new_note, true)
				new_sustain.speed = new_note.speed
		
				notes.append(new_sustain)
				ui.add_to_strum_group(new_sustain, new_sustain.must_press)

			ui.add_to_strum_group(new_note, new_note.must_press)
			notes.sort_custom(sort_notes)
			bleh += 1

	if notes.size() != 0:
		for note in notes:
			if note.spawned:
				var strum:Strum = ui.player_strums[note.dir] if note.must_press else ui.opponent_strums[note.dir]
				note.follow_song_pos(strum)
				if note.is_sustain:
					if note.must_press:
						if note.can_hit:
							#var check = (auto_play or Input.is_action_pressed(key_names[note.dir]))
							note.holding = (auto_play or Input.is_action_pressed(key_names[note.dir]))
							good_sustain_press(note, delta)
					else:
						if note.can_hit and !note.was_good_hit:
							opponent_sustain_press(note)
					
					if note.temp_len <= 0: kill_note(note)
				else:
					if note.must_press:
						if auto_play and note.strum_time <= Conductor.song_pos:
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

func beat_hit(beat):
	for i in characters:
		if beat % i.dance_beat == 0 and !i.animation.contains('sing'):
			i.dance()
		
	ui.icon_p1.bump()
	ui.icon_p2.bump()
	if stage.has_method('beat_hit'):
		stage.call('beat_hit')
	#var tick = AudioStreamPlayer.new()
	#add_child(tick)
	#tick.stream = load('res://assets/sounds/Metronome_Tick.ogg')
	#tick.play()
	#await tick.finished
	#tick.queue_free()

func step_hit(_step): pass

func section_hit(_section):
	if SONG.notes.size() <= cur_section + 1: return
	cur_section += 1
	section_data = SONG.notes[cur_section]
	ui.zoom += 0.04
	cam.zoom += Vector2(0.08, 0.08)
	
	move_cam(section_data.mustHitSection)
	if section_data.has('changeBPM') and section_data.has('bpm'):
		if section_data.changeBPM and Conductor.bpm != section_data.bpm:
			Conductor.bpm = section_data.bpm
			print('bpm changeded ' + str(section_data.bpm))

func move_cam(to_player:bool = true):
	var char = boyfriend if to_player else dad
	var cam_off:Vector2 = stage.bf_cam_offset if to_player else stage.dad_cam_offset
	var new_pos:Vector2 = char.get_cam_pos()
	cam.position = new_pos + cam_off

func _unhandled_key_input(_event):
	if auto_play: return
	for i in 4:
		if Input.is_action_just_pressed(key_names[i]): key_press(i)
		if Input.is_action_just_released(key_names[i]): key_release(i)

func key_press(key:int = 0):
	var hittable_notes:Array[Note] = notes.filter(func(i:Note):
		return i.spawned and !i.is_sustain and i.must_press and i.can_hit and i.dir == key and !i.was_good_hit
	)
	hittable_notes.sort_custom(sort_notes)
	
	if hittable_notes.size() != 0:
		var note:Note = hittable_notes[0]
			
		if hittable_notes.size() > 1:
			for funny in hittable_notes: # temp dupe note thing killer bwargh i hate it
				if note == funny: continue 
				if absf(funny.strum_time - note.strum_time) < 1.0:
					kill_note(funny)
				elif funny.strum_time < note.strum_time:
					note = funny; break
		good_note_hit(note)

	var strum = ui.player_strums[key]
	if !strum.animation.contains('confirm') and !strum.animation.contains('press'):
		strum.play_anim('press')
		strum.reset_timer = 0

func key_release(key:int = 0):
	ui.player_strums[key].play_anim('static')

func song_end():
	Conductor.reset()
	Game.switch_scene("menus/freeplay")
	#get_tree().reload_current_scene()

func event_hit(event:EventNote):
	print(event.event, event.values)
	match event.event:
		'Hey!':
			boyfriend.play_anim('hey', true)
			boyfriend.special_anim = true
			gf.play_anim('cheer', true)
			gf.special_anim = true
		'Change Scroll Speed': 
			var new_speed = SONG.speed * float(event.values[0])
			create_tween().tween_property(Game.scene, 'cur_speed', new_speed, float(event.values[1]))
		'Add Camera Zoom': print('yuh')
		_: false

func good_note_hit(note:Note):
	if note.type.length() > 0:
		print(note.type, ' bf')
	var char = boyfriend
	if note.type == 'GF Sing':
		char = gf
	strum_anim(note.dir, true)
	char.sing(note.dir)
	
	combo += 1
	
	var hit_rating = Judge.get_rating(Conductor.song_pos - note.strum_time)
	if Prefs.rating_cam != 'none':
		var cam:Callable = ui.add_behind if Prefs.rating_cam == 'hud' else add_child
		var new_rating = Judge.make_rating(hit_rating)
		cam.call(new_rating)
	
		var r_tween = create_tween()
		r_tween.tween_property(new_rating, "modulate:a", 0, 0.2).set_delay(Conductor.crochet * 0.001)
		r_tween.finished.connect(new_rating.queue_free)
	
		var new_nums = Judge.make_combo(combo)
		for num in new_nums:
			cam.call(num)
			var n_tween = create_tween()
			n_tween.tween_property(num, "modulate:a", 0, 0.2).set_delay(Conductor.crochet * 0.002)
			n_tween.finished.connect(num.queue_free)
	
	score += Judge.get_score(hit_rating)[0]
	ui.note_percent += Judge.get_score(hit_rating)[1]
	ui.total_hit += 1
	ui.hit_count[hit_rating] += 1
	ui.hp += 2.3
	
	if Prefs.note_splashes != 'none':
		if Prefs.note_splashes == 'all' or (Prefs.note_splashes == 'sicks' and hit_rating == 'sick'):
			ui.spawn_splash(ui.player_strums[note.dir])
			
	ui.update_score_txt()
	
	kill_note(note)
	if Prefs.hitsounds:
		GlobalMusic.play_sound('hitsound', 0.7)
	#	ui
	
func good_sustain_press(sustain:Note, delt:float = 0.0):
	if !auto_play and Input.is_action_just_released(key_names[sustain.dir]):
		#sustain.dropped = true
		note_miss(sustain)
		return
		
	if sustain.holding:
		score += floor(500 * delt)
		ui.hp += (4 * delt)
		ui.update_score_txt()
		if ui.player_strums[sustain.dir].anim_timer <= 0:
			strum_anim(sustain.dir, true)
			var char = boyfriend
			if sustain.type == 'GF Sing':
				char = gf
			char.sing(sustain.dir)
	
func opponent_note_hit(note:Note):
	if note.type.length() > 0:
		print(note.type, ' dad')
	var char = dad
	if note.type == 'GF Sing':
		char = gf
	var alt = '-alt' if section_data.has('altAnim') and section_data.altAnim else ''
	strum_anim(note.dir, false)
	char.sing(note.dir, alt)
	kill_note(note)

func opponent_sustain_press(sustain:Note):
	if ui.opponent_strums[sustain.dir].anim_timer <= 0:
		strum_anim(sustain.dir, false)
		var char = dad
		if sustain.type == 'GF Sing':
			char = gf
		var alt = '-alt' if section_data.has('altAnim') and section_data.altAnim else ''
		char.sing(sustain.dir, alt)
		
func note_miss(note:Note):
	boyfriend.sing(note.dir, 'miss')
	score -= 10 if !note.is_sustain else floor(note.length * 5)
	misses += 1
	ui.total_hit += 1
	ui.hp -= 4.7
	
	if combo > 5:
		var miss = Judge.make_combo('000')
		for num in miss:
			add_child(num)
			num.modulate = Color.DARK_RED
			var n_tween = create_tween()
			n_tween.tween_property(num, "modulate:a", 0, 0.2).set_delay(Conductor.crochet * 0.002)
			n_tween.finished.connect(num.queue_free)
		
	combo = 0
	
	if Conductor.vocals != null:
		Conductor.vocals.volume_db = -100
	ui.update_score_txt()
	#if !note.sustain: 
	kill_note(note)
	
func kill_note(note:Note):
	note.spawned = false
	notes.remove_at(notes.find(note))
	note.queue_free()

func strum_anim(dir:int = 0, player:bool = false):
	var strum:Strum = ui.player_strums[dir] if player else ui.opponent_strums[dir]

	if Conductor.vocals != null:
		Conductor.vocals.volume_db = 1
	strum.play_anim('confirm', true)
	strum.anim_timer = Conductor.step_crochet / 1000
	if !player or auto_play:
		strum.reset_timer = Conductor.step_crochet * 1.25 / 1000 #0.15
	
func sort_notes(a:Note, b:Note):
	return a.strum_time < b.strum_time
