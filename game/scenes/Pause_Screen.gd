extends Node2D

@export var option_list:Array[String] = ['Resume', 'Restart Song', 'Exit To Menu']
var options = []
var cur_option:int = 0
func _ready():
	Conductor.pause(true)
	GlobalMusic.set_music('breakfast')
	$BG.modulate.a = 0
	var twen = create_tween()
	twen.tween_property($BG, 'modulate:a', 0.6, 0.4).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	for i in option_list.size():
		var option = Alphabet.new()
		option.bold = true
		option.is_menu = true
		option.target_y = i
		option.text = option_list[i]
		options.append(option)
		add_child(option)
	#options = [$Option1, $Option2, $Option3]
	change_selection()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed('ui_up'):
		change_selection(-1)
	if Input.is_action_just_pressed('ui_down'):
		change_selection(1)
		
	if Input.is_action_just_pressed('Accept'):
		match options[cur_option].text.to_lower():
			'resume':
				close()
				Conductor.pause(false)
				get_tree().paused = false
			'restart song':
				close()
				Conductor.reset()
				Game.reset_scene()
			'exit to menu':
				close()
				Conductor.reset()
				Game.switch_scene('menus/freeplay')

func change_selection(amount:int = 0):
	GlobalMusic.play_sound('scrollMenu')
	cur_option = wrapi(cur_option + amount, 0, options.size())
	for i in options.size():
		options[i].target_y = i - cur_option
		options[i].modulate.a = (1 if i == cur_option else 0.6)

func close():
	GlobalMusic.stop()
	queue_free()
	get_tree().paused = false
