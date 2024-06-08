extends Node2D

var cur_section:int = 0
var total_notes = []

var strums = []

const GRID_SIZE:int = 40
var grid:NoteGrid
var total_grids = []

var selected:ColorRect
var last_notes:Array[Note] = []
var cur_notes:Array = []
var next_notes:Array[Note] = []

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
	
	$Info/BPM.value = SONG.bpm
	$Info/Song.text = SONG.song
	$StrumLine/Left.spacing = 108
	$StrumLine/Right.spacing = 108
	
	strums = $StrumLine/Left.get_strums()
	strums.append_array($StrumLine/Right.get_strums())
	
	#$NoteGroup/PlayIcon.change_icon(SONG.player1, true)
	#$NoteGroup/PlayIcon.default_scale = 0.7
	#$NoteGroup/OppIcon.change_icon(SONG.player2)
	#$NoteGroup/OppIcon.default_scale = 0.7
	
	for char in def_order: 
		$Info/Player1.add_item(char)
		$Info/Player2.add_item(char)
		$Info/GF.add_item(char)
		
	for char in DirAccess.get_files_at('res://assets/data/characters'):
		char = char.replace('.json', '')
		if def_order.has(char): continue
		$Info/Player1.add_item(char)
		$Info/Player2.add_item(char)
		$Info/GF.add_item(char)
		
	grid = NoteGrid.new(Vector2(GRID_SIZE, GRID_SIZE), Vector2(GRID_SIZE * 8, GRID_SIZE * 16))
	grid.position.x = 100
	grid.name = 'grid'
	add_child(grid)
	move_child(grid, get_node('Notes').get_index())
	
	selected = ColorRect.new()
	selected.custom_minimum_size = Vector2(GRID_SIZE, GRID_SIZE)
	$Notes.add_child(selected)
	$Notes.move_child(selected, 0)
	
	update_grids()

var time_pressed:float = 0 
var just_pressed:bool = false
func _process(delta):
	$Info/TimeTxt.text = 'Time: '+ str(Game.round_d(Conductor.song_pos, 1))
	
	$StrumLine.position.y = get_y_from_time(fmod(Conductor.song_pos - get_section_time(), Conductor.step_crochet * 16.0))
	#$StrumLine/Left.position.y = -20
	#$StrumLine/Right.position.y = -20
	
	$Cam.position = $StrumLine.position + Vector2(520, 50) # grid.position + Vector2(grid.width, grid.height / 2)
	$BG.position = $Cam.position
		
	if Input.is_physical_key_pressed(KEY_SPACE): # maybe see if i can find a better way for keys
		time_pressed += delta
		if !just_pressed and time_pressed >= 0.01:
			just_pressed = true
			toggle_play()
	else:
		just_pressed = false
		time_pressed = 0
	
	#TODO debug, remove this later
	if Input.is_action_just_pressed("menu_left"):
		$Cam.zoom -= Vector2(0.05, 0.05)
	if Input.is_action_just_pressed("menu_right"):
		$Cam.zoom += Vector2(0.05, 0.05)
	
	var mouse_pos = get_viewport().get_mouse_position() # mouse pos isnt affected by cam movement like flixel
	var cam_off = $Cam.get_screen_center_position() - (get_viewport_rect().size / 2.0) + Vector2(100, 0)
	mouse_pos += cam_off
	selected.position.x = floor(mouse_pos.x / GRID_SIZE) * GRID_SIZE - 100
	selected.position.y = mouse_pos.y if Input.is_key_pressed(KEY_SHIFT) else floor(mouse_pos.y / GRID_SIZE) * GRID_SIZE
	
	for note in cur_notes:
		if note is Note or note is ChartNote:
			if note.strum_time <= Conductor.song_pos and note.modulate != Color.GRAY:
				note.modulate = Color.GRAY
				Audio.play_sound('hitsound', 0.5)
				strums[note.true_dir].play_anim('confirm', true)
				strums[note.true_dir].reset_timer = 0.15
				
	if Input.is_action_just_pressed("back"):
		Conductor.reset_beats()
		Game.reset_scene()
		#Game.switch_scene('Play_Scene')
	
	if Input.is_physical_key_pressed(KEY_ENTER):
		Conductor.reset_beats()
		Game.switch_scene('Play_Scene')
		#JsonHandler._SONG.bpm = $Info/BPM.value
		#JsonHandler._SONG.player1 = $Info/Player1.text
		#JsonHandler._SONG.player2 = $Info/Player2.text
		#JsonHandler._SONG.gfVersion = $Info/GF.text

func beat_hit(beat:int):
	#$NoteGroup/OppIcon.bump(0.8)
	#$NoteGroup/PlayIcon.bump(0.8)
	
	if beat % 4 == 0:
		load_section(cur_section + 1)
		#print(str(Conductor.song_pos) +' | '+ str(get_section_time(cur_section)))

func toggle_play():
	Conductor.paused = !Conductor.paused
	
func load_section(section:int = 0, force_time:bool = false):
	if SONG.notes.size() > section:
		cur_section = section
		
		update_grids()
		if force_time:
			Conductor.song_pos = get_section_time(section)
	
func update_grids():
	while cur_notes.size() != 0:
		$Notes.remove_child(cur_notes[0])
		cur_notes[0].queue_free()
		cur_notes.remove_at(0)
		
	
	if SONG.notes[cur_section].has('changeBPM') and SONG.notes[cur_section].changeBPM:
		Conductor.bpm = max(SONG.notes[cur_section].bpm, 1)
	else:
		#get last bpm
		var last_bpm:int = SONG.bpm
		for i in cur_section:
			if SONG.notes[i].has('changeBPM') and SONG.notes[i].changeBPM:
				last_bpm = max(SONG.notes[i].bpm, 1)
		Conductor.bpm = last_bpm
	
	var new_sec = SONG.notes[cur_section].sectionNotes
	for info in new_sec:
		#print(info)
		var data = [info[0], info[1], null, info[2], false, (str(info[3]) if info.size() > 3 else '')]
		var new_note = ChartNote.new(NoteData.new(data), false, true)
		new_note.true_dir = info[1]
		$Notes.add_child(new_note)
		#move_child(new_note, 2)
		#new_note.note.centered = false
		new_note.scale = Vector2(0.26, 0.26)
		new_note.position.x = 120 + (GRID_SIZE * (info[1]))
		
		new_note.position.y = floori(get_y_from_time(fmod(floor(info[0]) - get_section_time(), Conductor.step_crochet * 16)))
		new_note.note.offset.y += GRID_SIZE * 2 #position.y += GRID_SIZE / 2 #round(new_note.note.texture.get_height() * 0.26 / 2)
		print(new_note.position)
		cur_notes.append(new_note)
		
		if info[2] > 0:
			var sustain = ColorRect.new() #Note.new(new_note, true, true)
			$Notes.add_child(sustain)
			$Notes.move_child(sustain, 0)
			sustain.position = new_note.position + Vector2(-4, 19)
			sustain.custom_minimum_size = Vector2(8, floori(remap(info[2], 0, Conductor.step_crochet * 16, 0, grid.height)))
			cur_notes.append(sustain)
	
	print('loaded '+ str(new_sec.size()) +' notes')
	

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
	load_section(0, true)

class ChartNote extends Note: # stupid
	var true_dir:int

class NoteGrid extends Control:
	var width:int
	var height:int
	var grid:Array = []
	
	func _init(cell_size:Vector2, grid_size:Vector2, colors:Array[Color] = []):
		if colors.size() == 0: colors = [Color.DIM_GRAY, Color.DARK_GRAY]
		
		var prev_col:Color = colors[0]
		var col:Color = prev_col
		var x:int = 0
		var y:int = 0
		while y < grid_size.y:
			if y > 0 and prev_col == col:
				prev_col = (colors[0] if prev_col == colors[0] else colors[1])
				
			x = 0
			while x < grid_size.x:
				if x == 0:
					col = prev_col
				var grid_square = ColorRect.new()
				grid_square.modulate = prev_col
				prev_col = (colors[0])
				colors.reverse()
				grid_square.position = Vector2(x, y)
				grid_square.custom_minimum_size = cell_size
				add_child(grid_square)
				grid.append(grid_square)
				x += cell_size.x
				
			y += cell_size.y
			
		print(x)
		width = x
		height = y
	
	func get_nearest(pos:Vector2 = Vector2.ZERO):
		for i in grid:
			var this = i.position
			pass

	#func _init(cell_size:Vector2, colors:Array[Color] = [Color.DIM_GRAY, Color.DARK_GRAY]):
	#	if cell_size == null: cell_size = Vector2(10, 10)
		
	#	var new_grid = GridContainer.new()
	#	new_grid.columns = 8
		
	#	width = cell_size.x * new_grid.columns
		
	#	var swap:bool = false
	#	var new_row:bool = false
	#	for i in 128:
	#		var grid_square = ColorRect.new()
	#		grid_square.custom_minimum_size = cell_size
	#		new_row = i % new_grid.columns == 0
	#		if new_grid.columns % 2 == 0 and new_row: 
				# only do this if its even since odd numbers dont have this problem
	#			colors.reverse()
	
	#		swap = (!swap if !new_row else true)
	#		if i % new_grid.columns == 0:
	#			height += cell_size.y
				
	#		grid_square.modulate = colors[1] if swap else colors[0]
				
	#		new_grid.add_child(grid_square)
	#	add_child(new_grid)
