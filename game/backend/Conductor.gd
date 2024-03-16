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

var cur_beat:int = 0
var cur_step:int = 0
var cur_section:int = 0

var embedded_song:String = '' # if load_song has no param, we'll check this var instead
var song_prepped:bool = false
var inst:AudioStreamPlayer
var vocals:AudioStreamPlayer

func load_song(song:String = ''):
	if song.length() < 1:
		if embedded_song.length() > 0:
			song = embedded_song
		else: 
			printerr('Conductor.load_song: NO SONG ENTERED')
			song = 'test' #DirAccess.get_directories_at('res://assets/songs')[0]
		
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
func start_song():
	played_audio = true
	if get_tree().current_scene.name == 'play_scene':
		song_end.connect(get_tree().current_scene.song_end)
		
	if inst != null: inst.play()
	if vocals != null: vocals.play()
	
func _ready():
	pass

func _process(delta):
	if song_prepped:
		song_pos += (1000 * delta)

	if song_pos > 0:
		if !played_audio: 
			start_song()
			return
		if inst != null: 
			if inst.playing: check_resync(inst)
			if song_pos >= inst.stream.get_length() * 1000:
				print('grah!!!')
				song_end.emit()
				get_tree().current_scene.call('song_end')
				song_pos = 0
				inst.stop()
				if vocals != null: vocals.stop()
				
		if vocals != null and vocals.playing: 
			check_resync(vocals)
				
func check_resync(sound:AudioStreamPlayer):
	if absf(sound.get_playback_position() * 1000 - song_pos) > 20:
		sound.seek(song_pos / 1000)
		print('resynced')
		
func reset():
	bpm = 100
	embedded_song = ''
	song_pos = 0
	played_audio = false
	song_prepped = false
