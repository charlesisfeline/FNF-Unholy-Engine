class_name Rating; extends RigidBody2D;

var init_pos:Vector2
var ratings_data:Dictionary = {
	'name':       ['sick', 'good', 'bad', 'shit'],
	'score':      [  350,    200,   100,    50],
	'hit_window': [   45,     90,   135,  null]
}

func _ready():
	$Sprite.scale = Vector2(0.5, 0.5)
	position = Vector2(get_viewport().size.x - 450, get_viewport().size.y - 300)
	init_pos = position

#func _process(delta):
#	position.y = lerpf(position.y, init_pos.y - 30, delta * 3)

var returned_index = 0
func get_rating_data(diff:float): # gets rating and score for the rating
	return [get_rating(diff), ratings_data.score[returned_index]]

func get_rating(diff:float):
	returned_index = 0
	for i in ratings_data.hit_window.size() - 1:
		var win = ratings_data.hit_window[i]
		if absf(diff) <= win:
			play_rating(i)
			return ratings_data.name[i]
		returned_index += 1
	play_rating(returned_index)
	return ratings_data.name[ratings_data.name.size() - 1]

func play_rating(index:int = 0):
	$Sprite.frame = index
	await get_tree().create_timer(Conductor.crochet * 0.001).timeout
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.2)
	#tween.tween_property(self, "position", Vector2(position.x, position.y - 20), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_callback(self.queue_free)
