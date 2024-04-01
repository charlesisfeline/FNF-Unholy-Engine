extends Node2D

@onready var menu_sprites = [$StoryMode, $Freeplay, $Donate, $Options]
var scene_to_load = ['story_mode', 'freeplay', 'donate', 'options_menu']
var cur_option:int = 0

func _ready():
	change_selection()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed('ui_down'):
		change_selection(1)
	elif Input.is_action_just_pressed('ui_up'):
		change_selection(-1)
	if Input.is_action_just_pressed('Accept'):
		if scene_to_load[cur_option] != null:
			GlobalMusic.play_sound('confirmMenu')
			if scene_to_load[cur_option] != 'donate':
				Game.switch_scene('menus/'+ scene_to_load[cur_option])
			else: OS.shell_open('https://ninja-muffin24.itch.io/funkin')
		else:
			GlobalMusic.play_sound('cancelMenu')
	if Input.is_action_just_pressed('ui_cancel'):
		GlobalMusic.play_sound('cancelMenu')
		Game.switch_scene('menus/title_scene')

func change_selection(by:int = 0):
	GlobalMusic.play_sound('scrollMenu')
	cur_option = wrapi(cur_option + by, 0, menu_sprites.size())
	menu_sprites[cur_option].play('selected')
	for i in menu_sprites.size():
		if i == cur_option: continue
		menu_sprites[i].play('normal')
