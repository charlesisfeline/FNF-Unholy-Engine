extends Node2D

var cur_section:int = 0
var total_notes = []

var strums = []

const GRID_SIZE:int = 40
const OFF:int = 100
var prev_grid:NoteGrid
var grid:NoteGrid
var next_grid:NoteGrid
var total_grids = []

var note_snap:int = 16
var cur_quant:int = 3:
	set(new_quant):
		cur_quant = wrap(new_quant, 0, quant_list.size() - 1)
		note_snap = quant_list[cur_quant]
		
var quant_list:Array[int] = [
	4, 8, 12, 16, 
	20, 24, 32, 48,
	64, 96, 192
]

var selected:ColorRect
var last_notes:Array = []
var cur_notes:Array = []
var next_notes:Array = []

# TODO
# add adding/removing notes
# buttons to move song position
# zooming/snapping
# fix grid colors
# make option buttons get the song chars
# add scroll speed option
# add other menus (to edit notes, sections and junk)
# add events

var def_order = [ # fuck you!!
	'bf', 'bf-car', 'bf-christmas', 'bf-pixel', 'bf-holding-gf', 'bf-pixel-opponent', 
	'bf-dead', 'bf-pixel-dead', 'bf-holding-gf-dead',
	'gf', 'gf-car', 'gf-christmas', 'gf-pixel', 'gf-tankmen', 
	'dad', 'spooky', 'monster', 'pico', 'mom', 'mom-car', 
	'parents-christmas', 'monster-christmas', 
	'senpai', 'senpai-angry', 'spirit', 'tankman', 'pico-speaker'
]

var SONG
func _ready():
	Conductor.reset()
	if JsonHandler.chart_notes.is_empty(): 
		JsonHandler.parse_song('dad-battle', 'hard', true)
	SONG = JsonHandler._SONG
	Conductor.load_song(SONG.song)
	Conductor.bpm = SONG.bpm
	
	if Conductor.vocals_opp.stream == null:
		tab('Chart', 'VoicesOpp').button_pressed = false
		tab('Chart', 'VoicesOpp').disabled = true
		tab('Chart', 'VoicesOpp/Vol').editable = false
		tab('Chart', 'VoicesOpp').modulate = Color.DIM_GRAY
		tab('Chart', 'VoicesOpp/Vol').modulate = Color.DIM_GRAY
		
	if Conductor.vocals.stream == null:
		tab('Chart', 'Voices').button_pressed = false
		tab('Chart', 'Voices').disabled = true
		tab('Chart', 'Voices/Vol').editable = false
		tab('Chart', 'Voices').modulate = Color.DIM_GRAY
		tab('Chart', 'Voices/Vol').modulate = Color.DIM_GRAY
		
	tab('Song', 'BPM').value = SONG.bpm
	tab('Song', 'Song').text = SONG.song
	tab('Song', 'Speed').value = SONG.speed
	$StrumLine/Left.spacing = 108
	$StrumLine/Right.spacing = 108
	
	strums = $StrumLine/Left.get_strums()
	strums.append_array($StrumLine/Right.get_strums())
	
	#$NoteGroup/PlayIcon.change_icon(SONG.player1, true)
	#$NoteGroup/PlayIcon.default_scale = 0.7
	#$NoteGroup/OppIcon.change_icon(SONG.player2)
	#$NoteGroup/OppIcon.default_scale = 0.7
	
	for char in def_order: 
		tab('Song', 'Player1').add_item(char)
		tab('Song', 'Player2').add_item(char)
		tab('Song', 'GF').add_item(char)
		
	for char in DirAccess.get_files_at('res://assets/data/characters'):
		char = char.replace('.json', '')
		if def_order.has(char): continue
		tab('Song', 'Player1').add_item(char)
		tab('Song', 'Player2').add_item(char)
		tab('Song', 'GF').add_item(char)
	
	set_dropdown(tab('Song', 'Player1'), SONG.player1)
	set_dropdown(tab('Song', 'Player2'), SONG.player2)
	var realgf = 'gf'
	if SONG.has('gfVersion') or SONG.has('player3'):
		realgf = SONG.gfVersion if SONG.has('gfVersion') else SONG.player3
	set_dropdown(tab('Song', 'GF'), realgf)
	
	grid = NoteGrid.new(Vector2(GRID_SIZE, GRID_SIZE), Vector2(GRID_SIZE * 8, GRID_SIZE * 16))
	grid.position.x = OFF
	grid.name = 'Grid'
	add_child(grid)
	move_child(grid, get_node('Notes').get_index())
	
	prev_grid = NoteGrid.new(Vector2(GRID_SIZE, GRID_SIZE), Vector2(GRID_SIZE * 8, GRID_SIZE * 16))
	prev_grid.position.x = OFF
	prev_grid.position.y = grid.position.y - grid.height
	prev_grid.modulate = Color.DIM_GRAY
	prev_grid.name = 'PrevGrid'
	add_child(prev_grid)
	move_child(prev_grid, get_node('Notes').get_index())
	
	next_grid = NoteGrid.new(Vector2(GRID_SIZE, GRID_SIZE), Vector2(GRID_SIZE * 8, GRID_SIZE * 16))
	next_grid.position.x = OFF
	next_grid.position.y = grid.position.y + grid.height
	next_grid.modulate = Color.DIM_GRAY
	next_grid.name = 'NextGrid'
	add_child(next_grid)
	move_child(next_grid, get_node('Notes').get_index())
	
	selected = ColorRect.new()
	selected.custom_minimum_size = Vector2(GRID_SIZE, GRID_SIZE)
	$Notes.add_child(selected)
	$Notes.move_child(selected, 0)
	
	update_grids()

var time_pressed:float = 0 
var just_pressed:bool = false

var mouse_pos
var holding_shift:bool = false
var over_grid:bool = false

func _process(delta):
	$StrumLine/TimeTxt.text = str(floor(Conductor.song_pos))
	var strum_y = round(get_y_from_time(fmod(Conductor.song_pos - get_section_time(), Conductor.step_crochet * 16.0)))
	$StrumLine.position.y = strum_y
	
	if strum_y >= grid.height - 3:
		#load_section(cur_section + 1)
		print('new section '+ str(cur_section))

	$Cam.position = $StrumLine.position + Vector2(520, 50) # grid.position + Vector2(grid.width, grid.height / 2)
	$BG.position = $Cam.position
	
	var audios = {'Inst' = Conductor.inst, 'Voices' = Conductor.vocals, 'VoicesOpp' = Conductor.vocals_opp}
	for aud in audios.keys():
		if !tab('Chart', aud).disabled and tab('Chart', aud).button_pressed:
			audios[aud].volume_db = linear_to_db(tab('Chart', aud +'/Vol').value)
		else:
			audios[aud].volume_db = linear_to_db(0)
			
	holding_shift = Input.is_key_pressed(KEY_SHIFT)
	mouse_pos = get_viewport().get_mouse_position() # mouse pos isnt affected by cam movement like flixel
	var cam_off = $Cam.get_screen_center_position() - (get_viewport_rect().size / 2.0) + Vector2(OFF, 0)
	mouse_pos += cam_off
	
	over_grid = mouse_pos.x > grid.position.x + OFF and mouse_pos.x < grid.position.x + grid.width + OFF \
		and mouse_pos.y > grid.position.y and mouse_pos.y < grid.position.y + (GRID_SIZE * 16)
	
	selected.visible = over_grid
	#if over_grid:
	selected.position.x = floor(mouse_pos.x / GRID_SIZE) * GRID_SIZE - OFF
	var y_pos = 0
	if holding_shift:
		y_pos = mouse_pos.y
	else:
		var snap:float = GRID_SIZE / (note_snap / 16.0)
		y_pos = floor(mouse_pos.y / snap) * snap
		
	selected.position.y = y_pos
	
	if !Conductor.paused:
		for note in last_notes:
			if note.is_sustain and note.hitting: # sustains that go over
				strums[wrap(note.true_dir, 0, 8)].play_anim('confirm', true)
				strums[wrap(note.true_dir, 0, 8)].reset_timer = 0.15
				
		for note in cur_notes:
			if note.strum_time <= Conductor.song_pos:
				if note.is_sustain:
					if note.hitting:
						strums[wrap(note.true_dir, 0, 8)].play_anim('confirm', true)
						strums[wrap(note.true_dir, 0, 8)].reset_timer = 0.15
				elif note.modulate != Color.GRAY:
					note.modulate = Color.GRAY

					if (tab('Chart', 'HitsoundsP').button_pressed and note.must_press)\
					 or(tab('Chart', 'HitsoundsO').button_pressed and !note.must_press):
						Audio.play_sound('hitsound', 0.3)
				
					strums[wrap(note.true_dir, 0, 8)].play_anim('confirm', true)
					strums[wrap(note.true_dir, 0, 8)].reset_timer = 0.15
				
	if Input.is_action_just_pressed("back"):
		Conductor.reset_beats()
		Game.reset_scene()
	
		#Game.switch_scene('Play_Scene')
	
		#JsonHandler._SONG.bpm = $Info/BPM.value
		#JsonHandler._SONG.player1 = $Info/Player1.text
		#JsonHandler._SONG.player2 = $Info/Player2.text
		#JsonHandler._SONG.gfVersion = $Info/GF.text

var bg_tween:Tween
func beat_hit(beat:int):
	#$NoteGroup/OppIcon.bump(0.8)
	#$NoteGroup/PlayIcon.bump(0.8)
	if tab('Chart', 'Metronome').button_pressed: 
		Audio.play_sound('tick', 0.8)
		$BG.scale = Vector2(1.02, 1.02)
		if bg_tween: bg_tween.kill()
		bg_tween = create_tween()
		bg_tween.tween_property($BG, 'scale', Vector2.ONE, Conductor.crochet / 3500)
		
	if beat % 4 == 0:
		load_section(cur_section + 1)
		#print(str(Conductor.song_pos) +' | '+ str(get_section_time(cur_section)))

func step_hit(step:int):
	update_text()

func toggle_play():
	Conductor.paused = !Conductor.paused
	
func set_dropdown(dropdown:OptionButton, to_val:String = ''): # set a optionbutton's value automatically
	if dropdown != null or to_val.length() > 0:
		var items:Array = []
		for i in dropdown.item_count:
			items.append(dropdown.get_item_text(i))
			
		if items.has(to_val):
			dropdown.select(items.find(to_val))

func tab(tab:String, node:String):
	return get_node('ChartUI/Tabs/'+ tab +'/'+ node)
		
func load_section(section:int = 0, force_time:bool = false):
	if SONG.notes.size() < section:
		return
		#var new = {
	#		'sectionNotes': [],
	#		'mustHitSection': false,
	#		'bpm': SONG.bpm,
	#		'changeBPM': false,
	#		'altAnim': false
	#	}
	#	SONG.notes.append(new)
		
	cur_section = max(section, 0)
	
	var sec = SONG.notes[cur_section]
	tab('Section', 'MustHit').button_pressed = sec.mustHitSection
	if sec.has('altAnim'):
		tab('Section', 'AltAnim').button_pressed = sec.altAnim or false
	if sec.has('changeBPM'):
		tab('Section', 'ChangeBPM').button_pressed = sec.changeBPM
		tab('Section', 'NewBPM').value = sec.bpm
	else:
		tab('Section', 'ChangeBPM').button_pressed = false
		tab('Section', 'NewBPM').value = 0
			
	if force_time:
		Conductor.song_pos = get_section_time(section)
		#nah bruh need something else
		var temp_time:float = 0
		var temp = {'beat': 0, 'beat_t': 0, 'step': 0, 'step_t': 0}
		var temp_croch = (60.0 / SONG.bpm) * 1000.0
		for i in cur_section:
			var bpm = SONG.bpm
			var da_sec = SONG.notes[i]
			if da_sec.has('changeBPM') and da_sec.changeBPM:
				bpm = max(da_sec.bpm, 1)
				temp_croch = (60.0 / bpm) * 1000.0
			#for j in 4:
			#	temp.beat_t += temp_croch

			temp_time += (60.0 / bpm) * 4000.0
			temp.beat_t += (60.0 / bpm) * 4000.0
			temp.beat += 4
			temp.step += 16
			temp.step_t += ((60.0 / bpm) * 4000.0) / 4
			
		#while temp_time < Conductor.song_pos:
		#	var bpm = SONG.bpm
		#	for i in cur_section:
		#		var da_sec = SONG.notes[i]
		#		if da_sec.has('changeBPM') and da_sec.changeBPM:
		#			bpm = max(da_sec.bpm, 1)
		#			temp_croch = (60.0 / bpm) * 1000.0
		#			print(bpm)
					
		#	temp_time += (60.0 / bpm) * 1000.0

		#	temp.beat_t += temp_croch
		#	temp.beat += 1
			
		#temp.step = temp.beat * 16
		#temp.step_t = temp.beat_t / 4.0
		
		Conductor.cur_beat = temp.beat
		Conductor.beat_time = temp.beat_t
	
		Conductor.cur_step = temp.step
		Conductor.step_time = temp.step_t

		Conductor.resync_audio()
		update_text()
		
	update_grids()
	
func _input(event): # this is better
	if event is InputEventMouseButton and !event.is_released() and over_grid:
		print('click')
		
		check_note()
		
	if Input.is_key_pressed(KEY_ENTER):
		Conductor.reset_beats()
		#JsonHandler._SONG = SONG
		#JsonHandler.generate_chart(SONG)
		Conductor.for_all_audio('volume_db', linear_to_db(1), true)
		Game.switch_scene('Play_Scene')
		
	if Input.is_key_pressed(KEY_SPACE):
		toggle_play()
	
	if Input.is_key_pressed(KEY_R):
		if holding_shift:
			cur_section = 0
			Conductor.reset_beats()
		load_section(cur_section, true)
		Conductor.paused = true
	
	if Input.is_key_pressed(KEY_A):
		load_section(cur_section - 1, true)
		Conductor.paused = true
	if Input.is_key_pressed(KEY_D):
		load_section(cur_section + 1, true)
		Conductor.paused = true
	if Input.is_key_pressed(KEY_W):
		pass
	if Input.is_key_pressed(KEY_S):
		pass
	if Input.is_key_pressed(KEY_LEFT):
		cur_quant -= 1
	if Input.is_key_pressed(KEY_RIGHT):
		cur_quant += 1
	
func update_grids():
	Game.remove_all([last_notes, cur_notes, next_notes], $Notes)
	#while last_notes.size() != 0:
	#	$Notes.remove_child(last_notes[0])
	#	last_notes[0].queue_free()
	#	last_notes.remove_at(0)
		
	#while cur_notes.size() != 0:
	#	$Notes.remove_child(cur_notes[0])
	#	cur_notes[0].queue_free()
	#	cur_notes.remove_at(0)
	
	#while next_notes.size() != 0:
	#	$Notes.remove_child(next_notes[0])
	#	next_notes[0].queue_free()
	#	next_notes.remove_at(0)
		
	if SONG.notes[cur_section].has('changeBPM') and SONG.notes[cur_section].changeBPM:
		Conductor.bpm = max(SONG.notes[cur_section].bpm, 1)
	else:
		#get last bpm
		var last_bpm:float = SONG.bpm
		for i in cur_section:
			if SONG.notes[i].has('changeBPM') and SONG.notes[i].changeBPM:
				last_bpm = max(SONG.notes[i].bpm, 1)
		Conductor.bpm = last_bpm

	$StrumLine/BPMTxt.text = str(Conductor.bpm) +' BPM'
	
	var last_sec = SONG.notes[cur_section - 1] if cur_section > 0 else null
	prev_grid.visible = last_sec != null
	if last_sec != null:
		for info in last_sec.sectionNotes:
			if info[1] == -1: continue
			if !(info[2] is float): info[2] = 0
			var must_press = (last_sec.mustHitSection and info[1] <= 3) or (!last_sec.mustHitSection and info[1] > 3)
			var type = (str(info[3]) if info.size() > 3 else '')
			var new_note = ChartNote.new([info[0], info[1], null, info[2], must_press, type], false)
			$Notes.add_child(new_note)
			
			do_note_shit(new_note, info[1])
			new_note.position.y = floori(get_y_from_time(fmod(floor(info[0]) - get_section_time(cur_section - 1), Conductor.step_crochet * 16))) - grid.height
			new_note.modulate = prev_grid.modulate
			
			last_notes.append(new_note)
		
			if info[2] > 0:
				var sustain = ChartNote.new(new_note, true) #ColorRect.new()
				$Notes.add_child(sustain)
				$Notes.move_child(sustain, 0)
				do_note_shit(sustain, new_note.true_dir)
			
				sustain.hold_group.size.x = 50 # close enough for now
				sustain.hold_group.size.y = floori(remap(info[2], 0, Conductor.step_crochet * 16.0, 0, prev_grid.height * 3.87))
			
				sustain.position = new_note.position + Vector2(-7, 40) #19)
				sustain.modulate = prev_grid.modulate
				sustain.alpha = 0.6
				last_notes.append(sustain)
				#var sustain = ColorRect.new() #Note.new(new_note, true, true)
				#$Notes.add_child(sustain)
				#$Notes.move_child(sustain, 0)
				#sustain.position = new_note.position + Vector2(-4, 40) #19)
				#sustain.custom_minimum_size = Vector2(8, floori(remap(info[2], 0, Conductor.step_crochet * 16, 0, grid.height)))
				#last_notes.append(sustain)
	
	var new_sec = SONG.notes[cur_section]
		
	for info in new_sec.sectionNotes:
		if info[1] == -1: continue
		if !(info[2] is float): info[2] = 0
		var must_press = (new_sec.mustHitSection and info[1] <= 3) or (!new_sec.mustHitSection and info[1] > 3)
		var type = (str(info[3]) if info.size() > 3 else '')
		var new_note = ChartNote.new([info[0], info[1], null, info[2], must_press, type], false)
		$Notes.add_child(new_note)
		
		do_note_shit(new_note, info[1])
		new_note.position.y = floori(get_y_from_time(fmod(floor(info[0]) - get_section_time(), Conductor.step_crochet * 16)))
	
		cur_notes.append(new_note)
		
		if info[2] > 0:
			var sustain = ChartNote.new(new_note, true) #ColorRect.new()
			$Notes.add_child(sustain)
			$Notes.move_child(sustain, 0)
			do_note_shit(sustain, new_note.true_dir)
			
			sustain.hold_group.size.x = 50 # close enough for now
			sustain.hold_group.size.y = floori(remap(info[2], 0, Conductor.step_crochet * 16.0, 0, grid.height * 3.87))
			
			sustain.position = new_note.position + Vector2(-7, 40) #19)
			
			cur_notes.append(sustain)
	
	var next_sec
	if SONG.notes.size() - 1 > cur_section + 1:
		next_sec = SONG.notes[cur_section + 1]
	#else:
		
	if next_sec != null:
		for info in next_sec.sectionNotes:
			if info[1] == -1: continue
			if !(info[2] is float): info[2] = 0
			var must_press = (next_sec.mustHitSection and info[1] <= 3) or (!next_sec.mustHitSection and info[1] > 3)
			var type = (str(info[3]) if info.size() > 3 else '')
			var new_note = ChartNote.new([info[0], info[1], null, info[2], must_press, type], false)
			$Notes.add_child(new_note)
			do_note_shit(new_note, info[1])
		
			new_note.position.y = floori(get_y_from_time(fmod(floor(info[0]) - get_section_time(cur_section + 1), Conductor.step_crochet * 16))) + grid.height
			
			new_note.modulate = next_grid.modulate
			next_notes.append(new_note)
		
			if info[2] > 0:
				var sustain = ChartNote.new(new_note, true) #ColorRect.new()
				$Notes.add_child(sustain)
				$Notes.move_child(sustain, 0)
				do_note_shit(sustain, new_note.true_dir)
			
				sustain.hold_group.size.x = 50 # close enough for now
				sustain.hold_group.size.y = floori(remap(info[2], 0, Conductor.step_crochet * 16.0, 0, next_grid.height * 3.87))
			
				sustain.position = new_note.position + Vector2(-7, 40) #19)
				sustain.modulate = next_grid.modulate
				sustain.alpha = 0.6
				
				next_notes.append(sustain)
				#var sustain = ColorRect.new() #Note.new(new_note, true, true)
				#$Notes.add_child(sustain)
				#$Notes.move_child(sustain, 0)
				#sustain.position = new_note.position + Vector2(-4, 40) #19)
				#sustain.custom_minimum_size = Vector2(8, floori(remap(info[2], 0, Conductor.step_crochet * 16, 0, next_grid.height)))
				#next_notes.append(sustain)
	
	print('loaded '+ str(new_sec.sectionNotes.size()) +' notes')
	
func do_note_shit(note, dir:int):
	note.true_dir = dir
	
	note.scale = Vector2(0.26, 0.26)
	if !note.is_sustain:
		note.position.x = 120 + (GRID_SIZE * (dir))
		note.note.offset.y += GRID_SIZE * 2
	
func check_note():
	pass
	
func add_note():
	var time = get_strum_from_y(selected.position.y) + get_section_time()
	var direct:int = floor(mouse_pos.x / GRID_SIZE) - 5
	
	SONG.notes[cur_section].sectionNotes.append([time, direct, 0])
	SONG.notes[cur_section].sectionNotes.sort_custom(func(a, b): return a[0] < b[0])
	
	update_grids()

func update_text():
	$ChartUI/Info.text = \
		"Beat: "+ str(Conductor.cur_beat) +"\n"+ \
		"Step: "+ str(Conductor.cur_step) +"\n"+ \
		"Sect: "+ str(cur_section)      +"\n\n"+ \
		"Snap: "+ str(note_snap) +"th"

func get_y_from_time(strum_time:float):
	return remap(strum_time, 0, 16 * Conductor.step_crochet, grid.position.y, grid.position.y + grid.height)

func get_strum_from_y(y_pos:float):
	return remap(y_pos, grid.position.y, grid.position.y + grid.height, 0, 16 * Conductor.step_crochet)

func get_section_time(this_sec:int = -1):
	if this_sec < 0: this_sec = cur_section
	var pos:float = 0
	var bpm:float = SONG.bpm
	for i in this_sec:
		var da_sec = SONG.notes[i]
		if da_sec.has('changeBPM') and da_sec.changeBPM:
			bpm = max(da_sec.bpm, 1)
		pos += 4.0 * (1000.0 * 60.0 / bpm)
	return pos

func song_end():
	Conductor.reset_beats()
	Conductor.start(0)
	Conductor.paused = true
	load_section(0, true)


class ChartNote extends Note: # stupid
	var true_dir:int
	var hitting:bool = false
	func _init(data, sustain:bool = false):
		if data is Array:
			data = NoteData.new(data)
		super(data, sustain, true)
	
	func resize_hold(update:bool = false, to_size:float = 0.0):
		#super(update)
		hold_group.size.y = to_size
		
	func _process(delta):
		super(delta)
		if is_sustain:
			hitting = strum_time <= Conductor.song_pos and strum_time + length > Conductor.song_pos
				
			

class NoteGrid extends Control:
	var width:int
	var height:int
	var grid:Array = []
	
	func _init(cell_size:Vector2, grid_size:Vector2, colors:Array[Color] = []):
		if colors.size() == 0: colors = [Color.DIM_GRAY, Color.DARK_GRAY]
		
		var prev_col:Color = colors[1]
		var x:int = 0
		var y:int = 0
		while y < grid_size.y:
			if y > 0:
				colors.reverse()
				prev_col = colors[1]
				
			x = 0
			while x < grid_size.x:
				var grid_square = ColorRect.new()
				grid_square.modulate = prev_col
				prev_col = colors[0] #if prev_col == colors[1] else colors[1]
				colors.reverse()
				grid_square.position = Vector2(x, y)
				grid_square.custom_minimum_size = cell_size
				add_child(grid_square)
				grid.append(grid_square)
				x += cell_size.x
				
			y += cell_size.y
	
		width = x
		height = y
		
		var center = ColorRect.new()
		center.custom_minimum_size = Vector2(3, height)
		center.modulate = Color.SLATE_GRAY
		center.position = position
		center.position.x += (width / 2) - 1.5
		add_child(center)
		
		for i in 4:
			var beat_mark = ColorRect.new()
			beat_mark.custom_minimum_size = Vector2(width, 2)
			beat_mark.modulate = Color.DARK_RED
			beat_mark.position = position
			beat_mark.position.y += (height / 4) * i
			add_child(beat_mark)
