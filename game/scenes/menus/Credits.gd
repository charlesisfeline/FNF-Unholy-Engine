extends Node2D

var credits = [
	['Test', 'face', 'He did', Color.ROSY_BROWN]
]
# Called when the node enters the scene tree for the first time.
func _ready():
	for i in credits:
		pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("accept"):
		pass
	if Input.is_action_just_pressed("back"):
		Game.switch_scene('menus/main_menu')
