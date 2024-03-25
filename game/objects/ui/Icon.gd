class_name Icon; extends Sprite2D;

var is_menu:bool = false # for freeplay icons, when i get around to it
var follow_spr = null
var image:String = 'face'
var is_player:bool = false

const min_width:int = 150 # if icon image is less or equal, theres only no lose anim
var has_lose:bool = false

func change_icon(image:String = 'face', is_player:bool = false):
	self.is_player = is_player
	self.image = image
	texture = load('res://assets/images/icons/icon-'+ image +'.png')
	has_lose = texture.get_width() > min_width
	hframes = 2 if has_lose else 1
	if is_player: flip_h = true
	
func _ready():
	change_icon()

func bump(to_scale:float = 1.2):
	scale = Vector2(to_scale, to_scale)
	
func _process(delta):
	if is_menu: return
	scale.x = lerpf(1, scale.x, exp(-delta * 15))
	scale.y = lerpf(1, scale.y, exp(-delta * 15))
	
	if follow_spr != null:
		if follow_spr is TextureProgressBar: # is healthbar or something
			var bar_width = follow_spr.texture_progress.get_size()[0]
			var cen = follow_spr.position.x + (bar_width * ((100 - follow_spr.value) * 0.01)) - 265
			if is_player:
				position.x = cen + (150 * scale.x - 150) / 2 - 26
			else:
				position.x = cen - (150 * scale.x) / 2 - 26 * 2
		
			position.y = -75 + (75 * scale.y) # goofy..
			
			if has_lose:
				if is_player:
					if follow_spr.value <= 20:
						frame = 1
					else: frame = 0
				else:
					if follow_spr.value >= 80:
						frame = 1
					else: frame = 0
		else:
			position = follow_spr.position
			position.x += offset.x
			position.y += offset.y
