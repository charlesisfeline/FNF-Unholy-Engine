extends Node2D
# prrobably for menus n shit i guess

signal changed_music

var Player = AudioStreamPlayer.new()
var pos:float = 0 # in case you need the position for something or whatever
var volume:float = 1
var music:String = "freakyMenu": # setter for if you KNOW the file exists, set_music for null checks
	set(track):
		if music != track:
			music = track
			Player.stream = load('res://assets/music/'+ track +'.ogg')
		else:
			Player.seek(0)
		pos = 0
		Player.play()

func _ready():
	add_child(Player)
	if (music != null or music.length() > 0) and get_tree().current_scene.name != 'Play_Scene':
		print(get_tree().current_scene.name)
		set_music(music)

func set_music(new_music:String, auto_play:bool = true):
	var path:String = 'assets/music/' + new_music + '.ogg'
	if FileAccess.file_exists('res://' + path):
		Player.stream = load('res://' + path)
		if auto_play:
			play_music()
	else: 
		printerr('MUSIC PLAYER | SET MUSIC: CAN\'T FIND FILE "' + path + '"')
	
func play_music(at_pos:float = -1):
	if Player.stream == null: # why not, fuck errors
		printerr('MUSIC PLAYER | PLAY_MUSIC: MUSIC IS NULL'); return
		
	if at_pos > -1:
		Player.seek(at_pos * 1000) # milliseconds
		pos = at_pos * 1000
	Player.play()

func stop(): Player.stop()
