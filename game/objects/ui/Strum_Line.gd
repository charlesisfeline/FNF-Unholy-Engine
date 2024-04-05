class_name Strum_Line; extends Node2D;

@export var is_cpu:bool = true:
	set(cpu): for i in get_strums(): i.is_player = !cpu
	
var spacing:float = 110

func _ready():
	for i in 4: # i can NOT be bothered to position these mfs manually
		var cur_strum:Strum = get_strums()[i]
		cur_strum.dir = (i % 4)
		cur_strum.downscroll = Prefs.get_pref('downscroll')
		#cur_strum.position.x = 150 / (1.5 if is_cpu else 0.45)
		#cur_strum.position.x += (spacing * i)
		#cur_strum.position.y = 550 if Prefs.get_pref('downscroll') else 110
		cur_strum.is_player = !is_cpu

func get_strums():
	return [$Strums/Left, $Strums/Down, $Strums/Up, $Strums/Right]
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

#func note_hit(note:Note):
#	pass
