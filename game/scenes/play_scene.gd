extends Node2D

@onready var camGAME = CanvasGroup.new()
@onready var camHUD = CanvasGroup.new()
var ui:UI
var STRUM = preload("res://game/objects/strum.tscn")
var NOTE = preload("res://game/objects/note.tscn")
var SUSTAIN = preload("res://game/objects/sustain.tscn")
var RATING = preload("res://game/objects/rating.tscn")

var SONG
var chart_notes
var notes:Array[Note] = []
var sustains:Array[Sustain] = []
var spawn_time:int = 2000

var player_strums:Array[Strum] = []
var opponent_strums:Array[Strum] = []
var keys = [
	InputMap.action_get_events('Note_Left'),
	InputMap.action_get_events('Note_Down'),
	InputMap.action_get_events('Note_Up'),
	InputMap.action_get_events('Note_Right')
]
const STRUMX = 150
var auto_play:bool = false

var score:int = 0
var misses:int = 0

func _ready():
	SONG = Conductor.load_song()
	print(SONG.song)
	
	var thread = Thread.new()
	thread.start(generate_chart.bind(SONG))
	add_child(camHUD)
	
	ui = UI.new()
	camHUD.add_child(ui)
	
	for i in 8:
		var new_strum:Strum = STRUM.instantiate()
		new_strum.dir = (i % 4)
		new_strum.position.x = STRUMX / (1.5 if i < 4 else 0.7)
		new_strum.position.x += (110 * i)
		new_strum.position.y = 550 if Prefs.get_pref('downscroll') else 110
		new_strum.is_player = (i > 3)
		camHUD.add_child(new_strum)
		if i <= 3: 
			opponent_strums.append(new_strum)
		else:
			player_strums.append(new_strum)
	Conductor.song_pos -= Conductor.crochet * 4
	await thread.wait_to_finish()

# Called every frame. 'delta' is the elapsed time since the previous frame.
var bleh:int = 0
var last_note:Note
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		auto_play = !auto_play
	if Input.is_action_just_pressed("Accept"): # lol
		Conductor.reset()
		get_tree().change_scene_to_file("res://game/scenes/debug_song_select.tscn")
		
	if chart_notes != null:
		while chart_notes.size() > 0 and bleh != chart_notes.size() and chart_notes[bleh][0] - Conductor.song_pos < spawn_time / SONG.speed:
			if chart_notes[bleh][0] - Conductor.song_pos > spawn_time / SONG.speed:
				break
			
			var is_sustain:bool = chart_notes[bleh][2]
			var new_note:Note = NOTE.instantiate()
			new_note.sustain_length = chart_notes[bleh][3]
			new_note.strum_time = chart_notes[bleh][0]
			new_note.dir = chart_notes[bleh][1] % 4
			new_note.must_press = chart_notes[bleh][4]
			new_note.spawned = true

			notes.append(new_note)
			add_child(new_note)

			if is_sustain:
				var _note:Note = new_note
				#var size = _note.sustain_length / Conductor.step_crochet
				
				#for i in loops + 1:
				last_note = notes[notes.size() - 1]
				var new_sustain:Sustain = SUSTAIN.instantiate()
				new_sustain.parent = _note
				new_sustain.dir = _note.dir
				new_sustain.length = _note.sustain_length
				new_sustain.strum_time = _note.strum_time + (Conductor.step_crochet / 16)
				new_sustain.da = 1 #absf((Conductor.song_pos - new_sustain.strum_time) - (new_sustain.length / SONG.speed)) / 70 #abs(floor((new_sustain.strum_time - new_sustain.length) - Conductor.song_pos) / 50) #_note.sustain_length / Conductor.step_crochet * 2.4
				print(new_sustain.da)#new_sustain.length * (0.45 * SONG.speed) + (((150 * 0.7) * 0.5) * SONG.speed))
				#
				
				#new_sustain.z_index = -1
				#new_sustain.scale.y *= Note.SUSTAIN_SIZE / 44;
				#new_sustain.scale.y *= Conductor.step_crochet / 100 * 1.05;
				add_child(new_sustain)
				#_note.sustain = new_sustain
				sustains.append(new_sustain)
			#cam_notes.add_child(new_note)
			notes.sort_custom(sort_notes)
			bleh += 1
			#print('bleh')
			
	if notes != null and notes.size() > 0:
		for note in notes:
			if note != null and note.spawned:
				var strum:Strum = player_strums[note.dir] if note.must_press else opponent_strums[note.dir]
			
				var pos:float = (0.45 * (Conductor.song_pos - note.strum_time) * SONG.speed)
				if !Prefs.get_pref('downscroll'): pos *= -1
				note.position.x = strum.position.x
				note.position.y = strum.position.y + pos
					
				if note.strum_time < Conductor.song_pos - 250 and note.must_press and !note.was_good_hit:
					note_miss(note)
				if note.was_good_hit && not note.must_press:
					opponent_note_hit(note)
					
				if auto_play and note.strum_time <= Conductor.song_pos and note.must_press:
					good_note_hit(note)
	for sustain in sustains:
		sustain.position.y = player_strums[0].position.y - (Conductor.song_pos - sustain.strum_time) * (0.45 * SONG.speed)
		if sustain.strum_time < Conductor.song_pos - sustain.length:
			sustains.remove_at(sustains.find(sustain))
			sustain.queue_free()

func _input(event):
	if auto_play: return
	if event is InputEventKey:
		var key:int = get_key(event.physical_keycode)
		if key < 0: return
		
		var press_array:Array[bool] = [
			Input.is_action_just_pressed('Note_Left'),
			Input.is_action_just_pressed('Note_Down'),
			Input.is_action_just_pressed('Note_Up'),
			Input.is_action_just_pressed('Note_Right')
		]
		var hold_array:Array[bool] = [
			Input.is_action_pressed('Note_Left'),
			Input.is_action_pressed('Note_Down'),
			Input.is_action_pressed('Note_Up'),
			Input.is_action_pressed('Note_Right')
		]
		
		var hittable_notes:Array[Note] = []
		var holdable_notes:Array[Sustain] = []
		
		for i in notes:
			if i != null and i.spawned and i.must_press and i.can_hit and i.dir == key and not i.was_good_hit: #and not i.can_cause_miss:
				hittable_notes.append(i)
		for i in sustains:
			if i != null and i.spawned and i.must_press:
				holdable_notes.append(i)
		
		if press_array[key]:
			if hittable_notes.size() > 0:
				var note:Note = hittable_notes[0]
				
				if hittable_notes.size() > 1:
					hittable_notes.sort_custom(sort_notes)
					
					var behind_note:Note = hittable_notes[1]
					
					if absf(behind_note.strum_time - note.strum_time) < 2.0:
						kill_note(behind_note)
					elif behind_note.dir == note.dir and behind_note.strum_time < note.strum_time:
						note = behind_note
				
				good_note_hit(note)
		if hold_array[key]:
			if holdable_notes.size() > 0:
				var sustain = holdable_notes[0]
				strum_anim(sustain.dir, true)
		if event.pressed:
			if hittable_notes.size() == 0:
				player_strums[key].play_anim('press')
		else:
			player_strums[key].play_anim('static')

func get_key(key:int) -> int:
	for i in keys.size():
		for event in keys[i]:
			if event is InputEventKey:
				if key == event.physical_keycode:
					return i
	return -1

func generate_chart(data):
	chart_notes = []
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
		
		
func song_end():
	Conductor.reset()
	get_tree().change_scene_to_file("res://game/scenes/debug_song_select.tscn")
	#get_tree().reload_current_scene()

func good_note_hit(note:Note):
	strum_anim(note.dir, true)

	var new_rating = RATING.instantiate()
	ui.add_child(new_rating)
	var data = new_rating.get_rating_data(note.strum_time - Conductor.song_pos)
	score += data[1] 
	ui.update_score_txt()
	
	kill_note(note)
	if Prefs.get_pref('hitsounds'):
		var hit = AudioStreamPlayer.new()
		add_child(hit)
		hit.stream = load('res://assets/sounds/hitsound.ogg')
		hit.play()
		await hit.finished
		hit.queue_free()
	
func opponent_note_hit(note:Note):
	strum_anim(note.dir, false)

	kill_note(note)

func note_miss(note:Note):
	score -= 10
	misses += 1
	if Conductor.vocals != null:
		Conductor.vocals.volume_db = -100
	ui.update_score_txt()
	kill_note(note)
	
func kill_note(note):
	note.spawned = false
	notes.remove_at(notes.find(note))
	note.queue_free()

func strum_anim(dir:int = 0, player:bool = false):
	var strum:Strum = player_strums[dir] if player else opponent_strums[dir]
	if Conductor.vocals != null:
		Conductor.vocals.volume_db = 1
	strum.play_anim('confirm')
	if !player or auto_play:
		strum.reset_timer = Conductor.step_crochet * 1.25 / 1000 #0.15
	
func sort_notes(a:Note, b:Note):
	return a.strum_time < b.strum_time
