extends AnimatedSprite2D
	
var ratings:Dictionary = {
	'sick': {'hit_window': 45,   'score': 350, 'hit_mod': 1},
	'good': {'hit_window': 90,   'score': 200, 'hit_mod': 0.67},
	'bad' : {'hit_window': 135,  'score': 100, 'hit_mod': 0.34},
	'shit': {'hit_window': null, 'score': 50,  'hit_mod': 0} 
}

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_rating(diff):
	for rating in ratings:
		if absf(diff) <= rating.hit_window:
			print(rating)
			return rating
	pass

func play_rating(rating:String = 'sick'):
	play(rating)
