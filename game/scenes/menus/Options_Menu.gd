extends Node2D

var catagories = ['Gameplay', 'Visuals', 'Controls']
var gameplay:Dictionary = {
	'downscroll': false,
	'middlescroll': false,
	'offset': 0,
	'sick_window': 45,
	'good_window': 90,
	'bad_window': 135,
	'safe_zone': 166
}
var visuals:Dictionary = {
	'FPS': 'Unlimited'
}
var controls = []
var cur_cata:int = 0
# make boxed... hold setting and infor abut seting...
var text_group:Array[Alphabet]
func _ready():
	for i in catagories.size():
		var item = catagories[i]
		var text = Alphabet.new()
		text.bold = true
		text.text = item
		text.position = Vector2(100, 100 + (100 * i))
		add_child(text)
		text_group.append(text)

func _process(delta):
	if Input.is_action_just_pressed('ui_cancel'):
		Game.switch_scene('menus/main_menu')
