class_name Rating; extends Resource;

var skin:SkinInfo = Game.scene.ui.SKIN
var path:String = 'res://assets/images/ui/skins/'
var rating_pos:Vector2 = Vector2(610, 500)
var combo_pos:Vector2 = Vector2(580, 560)
var spacing:float = 43

var ratings_data:Dictionary = {
	'name':       ['epic', 'sick', 'good', 'bad', 'shit', 'miss'],
	'score':      [500,   350,    200,   100,    50],
	'hit_window': [22.5,   45,     90,   135,  null],
	'penalty':    [1.0,   0.9,   0.73,  0.38,  0.10], # the lower it is, the harsher the score loss is
	# e = ~400-500, s = ~300, g = ~260, b = ~130, sh = ~30
	'hit_mod':    [1.0,   1.0,   0.75,   0.5,   0.2] # 1.0, 0.9, 0.7, 0.4, 0.2
}

func get_rating(diff:float) -> String:
	for i in ratings_data.hit_window.size() - 2:
		var win = Prefs.get(ratings_data.name[i] +'_window')
		if absf(diff) <= win:
			return ratings_data.name[i]
	return ratings_data.name[ratings_data.name.size() - 2] # miss should always be the last, so check the one before

func get_score(rating:String) -> Array:
	var index = ratings_data.name.find(rating)
	return [ratings_data.score[index], ratings_data.hit_mod[index], ratings_data.penalty[index]]

func make_rating(rate:String = 'sick') -> VelocitySprite:
	var rating = VelocitySprite.new()
	rating.position = rating_pos
	rating.texture = skin.rating_skin
	rating.vframes = ratings_data.name.size()
	rating.frame = ratings_data.name.find(rate.to_lower())
	
	rating.moving = true
	rating.velocity.y = randi_range(-140, -175)
	rating.acceleration.y = 550
	rating.scale = skin.rating_scale
	rating.antialiasing = skin.antialiased
	
	return rating

func make_combo(combo) -> Array[VelocitySprite]:
	var loops:int = 0
	var all_nums:Array[VelocitySprite] = []
	for i in str(combo).split():
		var num = VelocitySprite.new()
		num.position = combo_pos
		num.position.x += (spacing * loops)
		num.texture = skin.num_skin
		num.hframes = 10
		num.frame = int(i)
		all_nums.append(num)
		
		num.moving = true
		num.acceleration.y = randi_range(200, 300)
		num.velocity.y = randi_range(-140, -160)
		num.velocity.x = randf_range(-5, 5)
		
		num.scale = skin.num_scale
		num.antialiasing = skin.antialiased
		loops += 1

	return all_nums
