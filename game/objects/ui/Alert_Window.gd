class_name AlertWindow; extends Window

signal on_add
signal on_leave

## The types of windows you can use.
## Alert: Small window at the corner of the screen, removed after "life_time" reaches 0, or closed with a click
## Pop-up: Pops in the center of the screen, must close to continue
@export_enum('Alert', 'Pop-up', 'C') var WINDOW_TYPE:String
#@export_enum('Warn', 'Info', 'Check') var ALERT_TYPE:String

## Icon the window will have
@export var icon:String = ''
@export var window_title:String = 'ERROR!':
	set(new_tit): title = new_tit
@export var life_time:float = 1.5
@export var on:String = 'empty'
var text:String = 'This is an alert window':
	set(new):
		text = new
		$Text.text = new

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	on_leave.connect(remove)
	match WINDOW_TYPE:
		'Alert': 
			unfocusable = true
			popup()
		'Pop-up':
			exclusive = true
			popup_window = true
			popup_centered()
		
var leaving:bool = false
func _process(delta:float) -> void:
	life_time = max(life_time - delta, 0)
	if WINDOW_TYPE == 'Alert' and life_time <= 0:
		if !leaving:
			leaving = true
			var outta_here = create_tween()
			outta_here.tween_property(self, 'position:x', -size.x * 1.2, 0.4)
			outta_here.finished.connect(on_leave)

func remove() -> void:
	AlertHandler.alert_count -= 1
	
	queue_free()

func _on_close_requested() -> void:
	pass # Replace with function body.
