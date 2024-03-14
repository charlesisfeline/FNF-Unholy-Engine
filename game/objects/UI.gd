class_name UI; extends Node2D;

@onready var cur_scene = get_tree().current_scene
var score_txt:Label

func _ready():
	score_txt = Label.new()
	score_txt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_txt.text = 'Score: 0 - Misses: 0'
	score_txt.position = Vector2(get_viewport().size.x - 250, get_viewport().size.y - 50)
	add_child(score_txt)
	update_score_txt()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update_score_txt():
	var new_txt = 'Score: %s - Misses: %s'
	score_txt.text = new_txt % [cur_scene.score, cur_scene.misses]
