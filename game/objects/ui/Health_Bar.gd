class_name HealthBar; extends Control;

@onready var bar = $Bar
@onready var spr = $Sprite

var width:float:
	get: return $Bar.get_size()[0]
	
var height:float:
	get: return $Bar.get_size()[1]
	
var value:float = 50:
	set(new_val):
		value = new_val
		$Bar.value = value
		
var fill_mode:int = 1:
	set(new_fill):
		fill_mode = wrapi(new_fill, 0, 3)
		$Bar.fill_mode = fill_mode
		
var style_box:Dictionary = {'background': null, 'fill': null}
func set_colors(left:Color, right:Color) -> void: # i might use this maybe who knows
	if left != null: style_box.background.bg_color = left
	if right != null: style_box.fill.bg_color = right
	
func _ready():
	if $Sprite == null:
		var new = Sprite2D.new()
		new.name = 'Sprite'
		new.texture = load('res://assets/images/ui/healthBar.png')
		add_child(new)
	if $Bar == null:
		var new = ProgressBar.new()
		new.name = 'Bar'
		add_child(new)
	
	style_box.background = $Bar.get_theme_stylebox('background').duplicate()
	style_box.fill = $Bar.get_theme_stylebox('fill').duplicate()
#func _process(delta):
#	pass
