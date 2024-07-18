extends Node2D
# for menus n shit i guess

var exclude:Array = ['Play_Scene', 'Charting_Scene'] # scenes to not auto start music on
var Player = AudioStreamPlayer.new()
var volume:float = 1:
	set(vol): 
		volume = vol
		if Player.stream != null:
			Player.volume_db = linear_to_db(volume)
		
var pos:float = 0 # in case you need the position for something or whatever

var loop_music:bool = true
var music:String = "" #"freakyMenu" # current music being played
var sound_list:Array[AudioStreamPlayer] = [] # currently playing sounds

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS # note to self, figure out a better way for autopause instead of muting
	add_child(Player)
	Player.finished.connect(finished)
	if music.length() == 0 and !exclude.has(Game.scene.name):
		play_music('freakyMenu')

func _process(delta):
	if Player.stream != null:
		pos += delta * 1000

func set_music(new_music:String, vol:float = 1, looped:bool = true): # set the music without auto playing it
	var path:String = 'assets/music/'+ new_music +'.ogg'
	if FileAccess.file_exists('res://'+ path):
		Player.stream = load('res://'+ path)
		music = new_music
		volume = vol
		loop_music = looped
	else: 
		printerr('MUSIC PLAYER | SET MUSIC: CAN\'T FIND FILE "'+ path +'"')
	
# play the stated music. if called empty, will play the last stated track, if there is one
func play_music(to_play:String = '', looped:bool = true, vol:float = 1):
	if to_play.is_empty() and Player.stream == null: # why not, fuck errors
		printerr('MUSIC PLAYER | PLAY_MUSIC: MUSIC IS NULL')
		return
	
	if !to_play.is_empty(): #and to_play != music:
		set_music(to_play, vol, looped)
	
	if !music.is_empty():
		pos = 0
		Player.seek(0)
		Player.play()
	#Player.stream.volume_db = linear_to_db(vol)
	
func stop_music(clear:bool = true): # stop and clear the stream if needed
	Player.stop()
	if clear:
		Player.stream = null

func finished():
	print('blopr')
	if loop_music: play_music()
	Game.call_func('on_music_finish')
	
func play_sound(sound:String, vol:float = 1, use_skin:bool = false):
	if use_skin and !sound.begins_with('skins/'): 
		sound = 'skins/'+ Game.scene.cur_style +'/'+ sound

	var path = 'res://assets/sounds/%s.ogg' % sound
	var new_sound := AutoSound.new(path, vol)
	add_child(new_sound)
	new_sound.play()
	sound_list.append(new_sound)

func stop_all_sounds():
	for sound in sound_list:
		if sound != null and sound.stream != null and sound.playing:
			sound.stop()
			sound.stream = null
			remove_child(sound)
			sound_list.remove_at(sound_list.find(sound))

class AutoSound extends AudioStreamPlayer:
	func _init(sound_path:String = '', vol:float = 1):
		stream = load(sound_path)
		volume_db = linear_to_db(vol)
		finished.connect(finish)
		
	func finish():
		Audio.sound_list.remove_at(Audio.sound_list.find(self))
		queue_free()
