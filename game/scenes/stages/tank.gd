extends StageBase

func _ready():
	default_zoom = 0.9
	bf_pos = Vector2(810, 100)
	dad_pos = Vector2(20, 100)
	gf_pos = Vector2(200, 65)
	 
	$Clouds/Sprite.moving = true
	$Clouds/Sprite.position = Vector2(randi_range(-700, -100), randi_range(-20, -20))
	$Clouds/Sprite.velocity.x = randf_range(5, 15)
	
	var tank_boy = TankBG.new()
	$Tank.add_child(tank_boy)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func beat_hit():
	for tank in $Forground.get_children():
		tank.get_node('Sprite').frame = 0
		tank.get_node('Sprite').play('idle')
	$Watchtower/Sprite.frame = 0
	$Watchtower/Sprite.play('idle')

class TankBG extends AnimatedSprite2D:
	var off = Vector2(400, 1300)
	var speed:float = 0.0
	var angle:float = 0.0
	func _init():
		centered = false
		sprite_frames = load('res://assets/images/stages/tank/tankRolling.res')
		play('idle')
		speed = randf_range(5, 7)
		angle = randi_range(-90, 45)
	
	func _process(delta):
		angle += delta * speed
		rotation = deg_to_rad(angle - 90 + 15)
		position.x = off.x + 1500 * cos(PI / 180 * (angle + 180))
		position.y = off.y + 1100 * sin(PI / 180 * (angle + 180))
