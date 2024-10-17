class_name Icon; extends Sprite2D;

@export var image:String = 'face'
@export var is_player:bool = false
var is_menu:bool = false
var follow_spr = null

@export var default_scale:float = 1.0
@export var icon_speed:float = 15.0  
const MIN_WIDTH:int = 150 # if icon width is less or equal, theres no lose anim
var has_lose:bool = false

var antialiasing:bool = true:
	get: return texture_filter == CanvasItem.TEXTURE_FILTER_LINEAR
	set(anti):
		texture_filter = Game.get_alias(anti)

func change_icon(new_image:String = 'face', player:bool = false, credit:bool = false) -> void:
	if new_image.begins_with('icon-'): new_image.replace('icon-', '')
	is_player = player
	image = new_image
	var icon_path = 'res://assets/images/icons/icon-%s.png'
	if credit: icon_path = icon_path.replace('icons/', 'credits/').replace('icon-', '')
	if !ResourceLoader.exists(icon_path % image): image = 'face'
	texture = load(icon_path % image)
	
	if image.ends_with('-pixel'): antialiasing = false
	has_lose = texture.get_width() > MIN_WIDTH
	hframes = 2 if has_lose else 1
	if is_player: flip_h = true
	
#func _ready():
	#change_icon(image)

func bump(to_scale:float = 1.2) -> void:
	scale = Vector2(to_scale, to_scale)
	
func _process(delta):
	scale.x = lerpf(default_scale, scale.x, exp(-delta * icon_speed))
	scale.y = lerpf(default_scale, scale.y, exp(-delta * icon_speed))
	
	if follow_spr != null:
		if follow_spr is HealthBar: # is healthbar or something
			var bar_width = follow_spr.width
			var cen = (follow_spr.position.x + (bar_width * (remap(follow_spr.value, 0, 100, 100, 0) * 0.01))) - bar_width * 1.452
			if is_player:
				position.x = cen + (150 * scale.x - 150) / 2 - 26
			else:
				position.x = cen - (150 * scale.x) / 2 - 26 * 2
		
			position.y = -80 + (75 * scale.y) # goofy..
			
			if has_lose:
				if is_player:
					frame = 1 if follow_spr.value <= 20 else 0
				else:
					frame = 1 if follow_spr.value >= 80 else 0
		else:
			position = follow_spr.position
			position.x += follow_spr.width + 80
			position.y += texture.get_height() / 5
