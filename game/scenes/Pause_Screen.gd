extends Node2D

@export var option_list:Array[String] = ['Resume', 'Restart Song', 'Exit To Menu']

var fuckin_text = []
var cur_option:int = 0
func _ready():
	Conductor.pause(true)
	GlobalMusic.set_music('breakfast')
	$BG.modulate.a = 0
	var twen = create_tween()
	twen.tween_property($BG, 'modulate:a', 0.6, 0.4).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	fuckin_text = [$Option1, $Option2, $Option3]
	change_selection()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed('ui_up'):
		change_selection(-1)
	if Input.is_action_just_pressed('ui_down'):
		change_selection(1)
		
	if Input.is_action_just_pressed('Accept'):
		match option_list[cur_option]:
			'Resume':
				close()
				Conductor.pause(false)
				get_tree().paused = false
			'Restart Song':
				close()
				Conductor.reset()
				Game.reset_scene()
			'Exit To Menu':
				close()
				Conductor.reset()
				Game.switch_scene('debug_song_select')

func change_selection(amount:int = 0):
	GlobalMusic.play_sound('scrollMenu')
	cur_option = wrapi(cur_option + amount, 0, option_list.size())
	for i in option_list.size():
		fuckin_text[i].modulate.a = (1 if i == cur_option else 0.6)

func close():
	GlobalMusic.stop()
	queue_free()
	get_tree().paused = false
