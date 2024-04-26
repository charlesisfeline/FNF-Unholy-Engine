class_name Strum_Line; extends Node2D;

@export var is_cpu:bool = true:
	set(cpu): for i in get_strums(): i.is_player = !cpu
	
var spacing:float = 110

func _ready():
	for i in 4: # i can NOT be bothered to position these mfs manually
		var cur_strum:Strum = get_strums()[i]
		cur_strum.dir = (i % 4)
		cur_strum.downscroll = Prefs.downscroll
		cur_strum.is_player = !is_cpu

func get_strums():
	return [$Strums/Left, $Strums/Down, $Strums/Up, $Strums/Right]
	
func _process(_delta):
	pass
