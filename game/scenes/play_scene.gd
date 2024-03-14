extends Node2D

@onready var camGAME = CanvasGroup.new()
@onready var camHUD = CanvasGroup.new()
var ui:UI
var STRUM = preload("res://game/objects/strum.tscn")
var NOTE = preload("res://game/objects/note.tscn")
var RATING = preload("res://game/objects/rating.tscn")

var SONG
var chart_notes
var notes:Array[Note] = []
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
	generate_chart(SONG)
	add_child(camHUD)
	
	ui = UI.new()
	camHUD.add_child(ui)
	
	for i in 8:
		var new_strum:Strum = STRUM.instantiate()
		new_strum.dir = (i % 4)
		new_strum.position.x = STRUMX / (1.5 if i < 4 else 0.7)
		new_strum.position.x += (110 * i)
		new_strum.position.y = 110
		new_strum.is_player = (i > 3)
		camHUD.add_child(new_strum)
		if i <= 3: 
			opponent_strums.append(new_strum)
		else:
			player_strums.append(new_strum)
	Conductor.song_pos -= Conductor.crochet * 4

# Called every frame. 'delta' is the elapsed time since the previous frame.
var bleh = 0
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
			
			var new_note:Note = NOTE.instantiate()
			new_note.is_sustain = chart_notes[bleh][2]
			new_note.sustain_length = chart_notes[bleh][3]
			new_note.strum_time = chart_notes[bleh][0]
			new_note.dir = chart_notes[bleh][1] % 4
			new_note.must_press = chart_notes[bleh][4]
			new_note.spawned = true
			# SONG.notes.pop_at(0)
			notes.append(new_note)
			add_child(new_note)
			#notes.sort_custom(sort_notes)
			#cam_notes.add_child(new_note)
			bleh += 1
			#print('bleh')
			
	if notes != null and notes.size() > 0:
		for note in notes:
			if note != null and note.spawned:
				var strum:Strum = player_strums[note.dir] if note.must_press else opponent_strums[note.dir]
	#			
				note.position.x = strum.position.x
				note.position.y = strum.position.y - (Conductor.song_pos - note.strum_time) * (0.45 * SONG.speed)
				
				if note.strum_time < Conductor.song_pos - 250 and note.must_press and !note.was_good_hit:
					kill_note(note)
				if note.was_good_hit && not note.must_press:
					opponent_note_hit(note)
	#			
				if auto_play and note.strum_time <= Conductor.song_pos and note.must_press:
					good_note_hit(note)

func _input(event):
	if auto_play: return
	if event is InputEventKey:
		var key:int = get_key(event.physical_keycode)
		if key < 0: return
		
		var control_array:Array[bool] = [
			Input.is_action_just_pressed('Note_Left'),
			Input.is_action_just_pressed('Note_Down'),
			Input.is_action_just_pressed('Note_Up'),
			Input.is_action_just_pressed('Note_Right')
		]
		
		var hittable_notes:Array[Note] = []
		
		for i in notes:
			if i != null and i.spawned and i.must_press and i.can_hit and i.dir == key and not i.was_good_hit: #and not i.can_cause_miss:
				hittable_notes.append(i)
		
		if control_array[key]:
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
	
func opponent_note_hit(note:Note):
	strum_anim(note.dir, false)

	kill_note(note)

func kill_note(note):
	note.spawned = false
	notes.remove_at(notes.find(note))
	note.queue_free()

func strum_anim(dir:int = 0, player:bool = false):
	var strum:Strum = player_strums[dir] if player else opponent_strums[dir]
	strum.play_anim('confirm')
	strum.reset_timer = Conductor.step_crochet * 1.25 / 1000 #0.15
	
func sort_notes(a:Note, b:Note):
	return a.strum_time < b.strum_time
