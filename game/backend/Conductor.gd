extends Node2D

signal beat_hit(beat:int)
signal step_hit(step:int)
signal section_hit(section:int)
signal song_end

var bpm:float = 100:
	set(new_bpm):
		if new_bpm != bpm:
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

var embedded_song:String = '-!sustain-test' # if load_song has no param, we'll check this var instead
var song_prepped:bool = false
var inst:AudioStreamPlayer
var vocals:AudioStreamPlayer

func load_song(song:String = ''):
	if song.length() < 1:
		if embedded_song.length() > 0:
			song = embedded_song
		else: 
			printerr('Conductor.load_song: NO SONG ENTERED')
			song = 'tutorial' #DirAccess.get_directories_at('res://assets/songs')[0]
		
	var path:String = 'res://assets/songs/'+ song.replace(' ', '-') +'/audio/'
	if FileAccess.file_exists(path + 'Inst.ogg'):
		inst = get_tree().current_scene.get_node('InstPlayer')
		inst.stream = load(path + 'Inst.ogg')
	if FileAccess.file_exists(path + 'Voices.ogg'):
		vocals = get_tree().current_scene.get_node('VoicePlayer')
		vocals.stream = load(path + 'Voices.ogg')
	
	var json = FileAccess.open(path.replace('audio/', 'charts/hard.json'), FileAccess.READ)
	var parsed = JSON.parse_string(json.get_as_text()).song
	bpm = parsed.bpm
	song_prepped = true
	return parsed

var played_audio:bool = false
var paused:bool = false
func start_song():
	played_audio = true
	#if get_tree().current_scene.name == 'play_scene':
		#song_end.connect(get_tree().current_scene.song_end)
		
	if inst != null: inst.play()
	if vocals != null: vocals.play()
	
func _ready():
	pass

var test:float = 0
func _process(delta):
	if paused: return
	if song_prepped:
		song_pos += (1000 * delta)

	if song_pos > 0:
		if !played_audio: 
			start_song()
			return
		if inst != null: 
			if song_pos > beat_time + crochet:
				beat_time += crochet
				cur_beat += 1
				Game.call_func('beat_hit')
				if cur_beat % 4 == 0:
					cur_section += 1
					Game.call_func('section_hit')
			
			if song_pos > step_time + step_crochet:
				step_time += step_crochet
				cur_step += 1
				Game.call_func('step_hit')
			
			if inst.playing: check_resync(inst)
			if song_pos >= inst.stream.get_length() * 1000 and song_prepped:
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

#func get_bpm_changes(song):	
#	pass

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
	#embedded_song = ''
	played_audio = false
	song_prepped = false

func soft_reset():
	song_pos = 0
	beat_time = 0; step_time = 0;
	cur_beat = 0; cur_step = 0; cur_section = 0;
	last_beat = -1; last_step = -1; last_section = -1;
	paused = false
