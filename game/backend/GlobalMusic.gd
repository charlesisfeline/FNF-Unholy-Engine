extends Node2D
# prrobably for menus n shit i guess

signal changed_music

var Player = AudioStreamPlayer.new()
var pos:float = 0 # in case you need the position for something or whatever
var volume:float = 1
var loop:bool = true
var music:String = "freakyMenu" # setter for if you KNOW the file exists, set_music for null checks

func _ready():
	add_child(Player)
	Player.finished.connect(finished)
	if (music != null or music.length() > 0) and Game.scene.name != 'Play_Scene':
		set_music(music)

func _process(delta):
	if Player.stream != null:
		pos += delta * 1000

func set_music(new_music:String, volume:float = 1, looped:bool = true):
	var path:String = 'assets/music/' + new_music + '.ogg'
	if FileAccess.file_exists('res://' + path):
		Player.stream = load('res://' + path)
		Player.volume_db = volume
		play_music()
		loop = looped
	else: 
		printerr('MUSIC PLAYER | SET MUSIC: CAN\'T FIND FILE "' + path + '"')
	
func play_music(at_pos:float = -1):
	if Player.stream == null: # why not, fuck errors
		printerr('MUSIC PLAYER | PLAY_MUSIC: MUSIC IS NULL'); return
		
	if at_pos > -1:
		Player.seek(at_pos * 1000) # milliseconds
		pos = at_pos * 1000
	Player.play()

func finished():
	print('blopr')
	if loop: play_music(0)
	Game.call_func('on_music_finish')
	
func stop(): 
	Player.stop()
	Player.stream = null

func play_sound(sound:String):
	var we_playin = AudioStreamPlayer.new()
	add_child(we_playin)
	we_playin.stream = load('res://assets/sounds/'+ sound +'.ogg')
	we_playin.play()
	await we_playin.finished
	we_playin.queue_free()
