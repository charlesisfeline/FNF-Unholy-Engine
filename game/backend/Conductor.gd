extends Node2D

signal beat_hit(beat:int)
signal step_hit(step:int)
signal section_hit(section:int)
signal song_end

var bpm:float = 100:
	set(new_bpm):
		bpm = new_bpm
		crochet = ((60 / bpm) * 1000)
		step_crochet = crochet / 4

var crochet:float = ((60 / bpm) * 1000)
var step_crochet:float = crochet / 4
var song_pos:float = 0.0
#var offset:float = 0
var safe_zone:float = 166

var beat_time:float = 0
var step_time:float = 0
#var sec_time:float = 0

var cur_beat:int = 0
var cur_step:int = 0
var cur_section:int = 0

var last_beat:int = -1
var last_step:int = -1
var last_section:int = -1

var song_loaded:bool = false
var inst = AudioStreamPlayer.new()
var vocals = AudioStreamPlayer.new()
func _ready():
	add_child(inst)
	add_child(vocals)

func load_song(song:String = ''):
	if song.length() < 1:
		printerr('Conductor.load_song: NO SONG ENTERED')
		song = 'tutorial' #DirAccess.get_directories_at('res://assets/songs')[0]
		
	var path:String = 'res://assets/songs/'+ song.replace(' ', '-') +'/audio/%s.ogg'
	if FileAccess.file_exists(path % ['Inst']):
		inst.stream = load(path % ['Inst'])
	if FileAccess.file_exists(path % ['Voices']):
		vocals.stream = load(path % ['Voices'])
	
	song_loaded = true

var song_started:bool = false
var paused:bool = false
func start_song():
	song_started = true
	#if get_tree().current_scene.name == 'play_scene':
		#song_end.connect(get_tree().current_scene.song_end)
		
	if inst != null: inst.play()
	if vocals != null: vocals.play()
	
var test:float = 0
func _process(delta):
	if paused: return
	if song_loaded:
		song_pos += (1000 * delta)

	if song_pos > 0:
		if !song_started: 
			start_song()
			return
		if inst != null: 
			if song_pos > beat_time + crochet:
				beat_time += crochet
				cur_beat += 1
				Game.call_func('beat_hit', [cur_beat])
				if cur_beat % 4 == 0:
					cur_section += 1
					Game.call_func('section_hit', [cur_section])
			
			if song_pos > step_time + step_crochet:
				step_time += step_crochet
				cur_step += 1
				Game.call_func('step_hit', [cur_step])
			
			if inst.playing: check_resync(inst)
			if song_pos >= inst.stream.get_length() * 1000 and song_loaded:
				print('grah!!!')
				song_pos = 0
				
				#song_end.emit()
				Game.call_func('song_end')
				inst.stop()
				if vocals != null: vocals.stop()
				
		if vocals != null and vocals.playing: 
			check_resync(vocals)
				
func check_resync(sound:AudioStreamPlayer):
	if absf(sound.get_playback_position() * 1000 - song_pos) > 20:
		sound.seek(song_pos / 1000)
		print('resynced')

func pause(force_to:bool):
	paused = (force_to if force_to != null else !paused)
	if paused:
		inst.stop()
		if vocals != null: vocals.stop()
	else:
		inst.play()
		if vocals != null: vocals.play()

func reset():
	soft_reset()
	bpm = 100
	
	song_started = false
	song_loaded = false
	inst.stream = null
	vocals.stream = null

func soft_reset():
	song_pos = 0
	beat_time = 0; step_time = 0;
	cur_beat = 0; cur_step = 0; cur_section = 0;
	last_beat = -1; last_step = -1; last_section = -1;
	paused = false
