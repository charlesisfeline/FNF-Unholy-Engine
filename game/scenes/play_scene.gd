extends Node2D

@onready var camGAME = CanvasGroup.new()
@onready var camHUD = CanvasGroup.new()
var ui:UI
var STRUM = preload("res://game/objects/strum.tscn")
var NOTE = preload("res://game/objects/note.tscn")
var SUSTAIN = preload("res://game/objects/sustain.tscn")
var RATING = preload("res://game/objects/rating.tscn")
var NUMS = preload("res://game/objects/combo_nums.tscn")
var BAR = preload("res://game/objects/ui/health_bar.tscn")
var ICON = preload("res://game/objects/ui/icon.tscn")

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
var key_names = ['Note_Left', 'Note_Down', 'Note_Up', 'Note_Right']

@export var STRUMX = 150
@export var auto_play:bool = true

var health_bar = BAR.instantiate()
var icon_p1 = ICON.instantiate()
var icon_p2 = ICON.instantiate()

var score:int = 0
var combo:int = 0
var misses:int = 0

func _ready():
	SONG = JsonHandler.parse_song(Conductor.embedded_song)
	Conductor.load_song()
	print(SONG.song)
	
	#SONG.speed = 10
	var thread = Thread.new()
	#thread.start(JsonHandler.generate_chart.bind(SONG)) 
	# since im doing something different, this thread will need to be changed
	chart_notes = JsonHandler.generate_chart(SONG)
	add_child(camHUD)
	
	icon_p1.change_icon('bf', true)
	icon_p2.change_icon('face')
	health_bar.position.x = 260
	health_bar.position.y = 575
	icon_p1.position.y = health_bar.position.y + 75
	icon_p2.position.y = health_bar.position.y + 75
	
	ui = UI.new()
	camHUD.add_child(ui)
	camHUD.add_child(health_bar)
	camHUD.add_child(icon_p1)
	camHUD.add_child(icon_p2)
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
	#await thread.wait_to_finish()

var cur_section:int = 0
var section_data

var global_delta:float = 0
var bleh:int = 0
var hp:float = 50
var last_note:Note
func _process(delta):
	global_delta = delta
	health_bar.value = lerpf(health_bar.value, hp, delta * 7)
	var hp_width = health_bar.texture_progress.get_size()[0]
	var cen = health_bar.position.x + (hp_width * ((100 - health_bar.value) * 0.01))
	
	var icon_offset = -50
	icon_p1.position.x = cen + (150 * icon_p1.scale.x - 150) / 2 - icon_offset
	icon_p2.position.x = cen - (150 * icon_p2.scale.x) / 2 - icon_offset / 2
	
	icon_p1.position.y = (health_bar.position.y - 75) + (75 * icon_p1.scale.x)
	icon_p2.position.y = (health_bar.position.y - 75) + (75 * icon_p2.scale.x)
	
	if health_bar.value <= 20:
		icon_p1.frame = 1
	else: icon_p1.frame = 0

	if health_bar.value >= 80:
		icon_p2.frame = 1
	else: icon_p2.frame = 0
	
	if Input.is_action_just_pressed("ui_cancel"):
		auto_play = !auto_play
	if Input.is_action_just_pressed("Accept"): # lol
		#get_tree().paused = !get_tree().paused
		Conductor.reset()
		get_tree().change_scene_to_file("res://game/scenes/debug_song_select.tscn")
		
	if chart_notes != null:
		while chart_notes.size() > 0 and bleh != chart_notes.size() and chart_notes[bleh][0] - Conductor.song_pos < spawn_time / SONG.speed:
			if chart_notes[bleh][0] - Conductor.song_pos > spawn_time / SONG.speed:
				break
			
			var is_sustain:bool = chart_notes[bleh][2]
			var new_note:Note = NOTE.instantiate()
			new_note.sustain_length = chart_notes[bleh][3]
			new_note.strum_time = floor(chart_notes[bleh][0])
			new_note.dir = chart_notes[bleh][1] % 4
			new_note.must_press = chart_notes[bleh][4]
			new_note.spawned = true

			notes.append(new_note)
			add_child(new_note)

			if is_sustain:
				var _note:Note = new_note
				
				last_note = notes[notes.size() - 1]
				var new_sustain:Sustain = SUSTAIN.instantiate()
				new_sustain.parent = _note
				new_sustain.copy_parent()

				#new_sustain.strum_time = _note.strum_time #+ (Conductor.step_crochet / 16)
				new_sustain.da = roundf((new_sustain.length / 50) * (0.45 * SONG.speed))
				
				#new_sustain.z_index = -1
				add_child(new_sustain)

				sustains.append(new_sustain)
			#cam_notes.add_child(new_note)
			notes.sort_custom(sort_notes)
			bleh += 1
			
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
		var strum = player_strums[sustain.dir] if sustain.must_press else opponent_strums[sustain.dir]
		sustain.position.y = strum.position.y - (0.45 * (Conductor.song_pos - sustain.strum_time) * SONG.speed) + sustain.offset
		
		if sustain.can_hit:
			if !sustain.must_press:
				opponent_sustain_press(sustain)
			else:
				var check = (Input.is_action_pressed(key_names[sustain.dir]) or auto_play)
				sustain.holding = check
				if check: good_sustain_press(sustain)
				
			if sustain.was_good_hit:
				sustains.remove_at(sustains.find(sustain))
				sustain.queue_free()
				
			if sustain.strum_time < (Conductor.song_pos - sustain.length) and !sustain.was_good_hit:
				print('limit')
				sustains.remove_at(sustains.find(sustain))
				sustain.queue_free()

func beat_hit():
	icon_p1.scale = Vector2(1.2, 1.2)
	icon_p2.scale = Vector2(1.2, 1.2)
	#var tick = AudioStreamPlayer.new()
	#add_child(tick)
	#tick.stream = load('res://assets/sounds/Metronome_Tick.ogg')
	#tick.play()
	#await tick.finished
	#tick.queue_free()

func step_hit(): pass

func section_hit():
	if SONG.notes.size() <= cur_section + 1: return
	cur_section += 1
	section_data = SONG.notes[cur_section]
	if section_data.has('changeBPM') and section_data.has('bpm'):
		if section_data.changeBPM and Conductor.bpm != section_data.bpm:
			Conductor.bpm = section_data.bpm
			print('bpm changeded ' + str(section_data.bpm))

func _input(event): 
	if auto_play || !(event is InputEventKey): return

	var key:int = get_key(event.physical_keycode)
	if key < 0: return
	
	# i dont use this for hold notes because it takes like half a second before a key counts as "held"
	var press_array:Array[bool] = []
	for i in key_names:
		press_array.append(Input.is_action_just_pressed(i))

	var hittable_notes:Array[Note] = []
		
	for i in notes:
		var can_hit:bool = i.spawned and i.must_press and i.can_hit and i.dir == key and !i.was_good_hit
		if can_hit: hittable_notes.append(i)
	hittable_notes.sort_custom(sort_notes)
	
	if press_array[key]:
		if hittable_notes.size() != 0:
			var note:Note = hittable_notes[0]
			
			if hittable_notes.size() > 1:
				var behind_note:Note = hittable_notes[1]
				
				if absf(behind_note.strum_time - note.strum_time) < 1.0:
					kill_note(behind_note)
				elif behind_note.dir == note.dir and behind_note.strum_time < note.strum_time:
					note = behind_note
			
			good_note_hit(note)

	var strum = player_strums[key]
	if event.pressed and !strum.animation.contains('confirm') and !strum.animation.contains('press'):
		strum.play_anim('press')
		strum.reset_timer = 0
	elif event.is_released():
		strum.play_anim('static')

func get_key(key:int) -> int:
	for i in keys.size():
		for event in keys[i]:
			if event is InputEventKey:
				if key == event.physical_keycode:
					return i
	return -1

func song_end():
	Conductor.reset()
	get_tree().change_scene_to_file("res://game/scenes/debug_song_select.tscn")
	#get_tree().reload_current_scene()

func good_note_hit(note:Note):
	strum_anim(note.dir, true)

	combo += 1
	var new_rating = RATING.instantiate()
	ui.add_child(new_rating)
	new_rating.linear_velocity.y = randi_range(-200, -300)
	#new_rating.linear_velocity.x -= randi_range(0, 10)
	new_rating.apply_central_force(-new_rating.linear_velocity * 0.2)
	
	var data = new_rating.get_rating_data(note.strum_time - Conductor.song_pos)
	score += data[1]
	hp += 2.3
	
	var loops:int = 0
	for i in str(combo).split():
		var new_num = NUMS.instantiate()
		new_num.frame = int(i)
		ui.add_child(new_num)

		new_num.position.x += (38 * loops)
		loops += 1

		
	ui.update_score_txt()
	
	kill_note(note)
	if Prefs.get_pref('hitsounds'):
		var hit = AudioStreamPlayer.new()
		add_child(hit)
		hit.stream = load('res://assets/sounds/hitsound.ogg')
		hit.play()
		await hit.finished
		hit.queue_free()
	
func good_sustain_press(sustain:Sustain):
	if player_strums[sustain.dir].anim_timer <= 0:
		strum_anim(sustain.dir, true)
	
func opponent_note_hit(note:Note):
	strum_anim(note.dir, false)

	kill_note(note)

func opponent_sustain_press(sustain:Sustain):
	if opponent_strums[sustain.dir].anim_timer <= 0:
		strum_anim(sustain.dir, false)
	
func note_miss(note:Note):
	score -= 10
	misses += 1
	hp -= 4.7
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
	strum.play_anim('confirm', true)
	strum.anim_timer = Conductor.step_crochet / 1000
	if !player or auto_play:
		strum.reset_timer = Conductor.step_crochet * 1.25 / 1000 #0.15
	
func sort_notes(a:Note, b:Note):
	return a.strum_time < b.strum_time
