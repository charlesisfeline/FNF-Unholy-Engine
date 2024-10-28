class_name AlertWindow; extends Window

signal on_add
signal on_leave

## The types of windows you can use.
## Alert: Small window at the corner of the screen, removed after "life_time" reaches 0, or closed with a click
## Pop-up: Pops in the center of the screen, must close to continue
@export_enum('Alert', 'Pop-up', 'C') var WINDOW_TYPE:String

## Icon the window will have
@export var icon:String = ''
@export var window_title:String = 'ERROR!':
	set(new_tit): title = new_tit
@export var life_time:float = 1.5
@export var on:String = 'empty'

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match WINDOW_TYPE:
		'Alert': 
			unfocusable = true
			popup()
		'Pop-up':
			exclusive = true
			popup_window = true
			popup_centered()
		
func _process(delta:float) -> void:
	life_time = max(life_time - delta, 0)
	if WINDOW_TYPE == 'Alert' and life_time <= 0:
		pass


func _on_about_to_popup() -> void:
	pass # Replace with function body.


func _on_close_requested() -> void:
	pass # Replace with function body.
