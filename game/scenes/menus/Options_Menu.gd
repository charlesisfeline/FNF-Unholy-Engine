extends Node2D

var catagories = ['Gameplay', 'Visuals', 'Controls']
var cur_cata:int = 0
# make boxed... hold setting and infor abut seting...
var text_group:Array[Alphabet]
func _ready():
	for i in catagories.size():
		var item = catagories[i]
		var text = Alphabet.new()
		text.bold = true
		text.text = item
		text.position = Vector2(100, 100 + (70 * i))
		add_child(text)
		text_group.append(text)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
