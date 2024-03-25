class_name Rating; extends Node2D;

var init_pos:Vector2
var ratings_data:Dictionary = {
	'name':       ['sick', 'good', 'bad', 'shit'],
	'score':      [  350,    200,   100,    50],
	'hit_window': [   45,     90,   135,  null]
}
var spr = VelocitySprite.new()

func _ready():
	spr.texture = load('res://assets/images/ui/ratings.png')
	spr.hframes = 4
	spr.scale = Vector2(0.5, 0.5)
	spr.position = Vector2(610, 300)
	init_pos = spr.position
	add_child(spr)

#func _process(delta):
#	position.y = lerpf(position.y, init_pos.y - 30, delta * 3)

var returned_index = 0
func get_rating_data(diff:float): # gets rating and score for the rating
	return [get_rating(diff), ratings_data.score[returned_index]]

func get_rating(diff:float):
	returned_index = 0
	for i in ratings_data.hit_window.size() - 1:
		var win = Prefs.get_pref(ratings_data.name[i] + '_window')
		if absf(diff) <= win:
			play_rating(i)
			return ratings_data.name[i]
		returned_index += 1
	play_rating(returned_index)
	return ratings_data.name[ratings_data.name.size() - 1]

func play_rating(index:int = 0):
	spr.frame = index
	spr.moving = true
	await get_tree().create_timer(Conductor.crochet * 0.001).timeout
	var tween = get_tree().create_tween()
	tween.tween_property(spr, "modulate", Color.TRANSPARENT, 0.2)
	#tween.tween_property(self, "position", Vector2(position.x, position.y - 20), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.finished.connect(spr.queue_free)
