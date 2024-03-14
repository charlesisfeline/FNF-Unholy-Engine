extends Node2D
# prrobably for menus n shit i guess

signal changed_music

var cur_track:String = "nuttin":
	set(track):
		if cur_track != track and FileAccess.file_exists('res://assets/music/'+ track +'.ogg'):
			cur_track = track
			$Player.stream = load('res://assets/music/'+ track +'.ogg')
		else:
			$Player
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
