extends StageBase

var windows:Array = ['31A2FD', '31FD8C', 'FB33F5', 'FD4531', 'FBA633'] # window colors so fancy wow woah woaoh

var train:Train = Train.new(Vector2(2000, 360))
func _ready():
	default_zoom = 1.05
	
	bf_pos += Vector2(70, -50)
	dad_pos += Vector2(100, -50)
	gf_pos.x += 100
	add_child(train)
	move_child(train, 4)

func _process(delta):
	$Windows/Sprite.self_modulate.a -= (Conductor.crochet / 1000) * delta * 1.5

func beat_hit(beat:int):
	train.beat_hit(beat)
	if beat % 4 == 0:
		var cur_col = windows[randi_range(0, windows.size() - 1)]
		$Windows/Sprite.self_modulate = Color(cur_col)
	
class Train extends Sprite2D:
	var active:bool = false
	var started:bool = false
	var stopping:bool = false
	
	var frame_limit:float = 0.0
	var sound := AudioStreamPlayer.new()
	var cars:int = 8
	var cooldown:int = 0
	
	func _init(pos:Vector2):
		centered = false
		position = pos
		texture = load('res://assets/images/stages/philly/train.png')
		sound.stream = load('res://assets/sounds/train_passes.ogg')
		add_child(sound)
		
	func _process(delta):
		if active:
			frame_limit += delta
			if frame_limit >= 1.0 / 24.0: #you gotta be kidding me
				frame_limit = 0.0
				if sound.get_playback_position() >= 4.7:
					started = true
					if Game.scene.gf.has_anim('hairBlow'):
						Game.scene.gf.play_anim('hairBlow')
						Game.scene.gf.can_dance = false
					#var last_frame:int = Game.scene.gf.frame
					#Game.scene.gf.play_anim(Game.scene.gf.animation +'-hair')
					#Game.scene.gf.frame = last_frame
					
				if started:
					position.x -= 400
					if position.x < -2000 && !stopping:
						position.x = -1150
						cars -= 1
						if cars < 1:
							stopping = true
					
					if position.x < -4000 && stopping:
						restart()
						
	var dance_gf:bool = false
	func beat_hit(beat:int):
		if !active:
			cooldown += 1

		if beat % 8 == 4 && Game.rand_bool(30) && !active && cooldown > 8: # 30
			cooldown = randi_range(-4, 0)
			active = true
			sound.play(0)
				
	func restart() -> void:
		var geef:Character = Game.scene.gf
		if geef.has_anim('hairFall'):
			geef.play_anim('hairFall')
			geef.special_anim = true
			geef.danced = false
			geef.can_dance = true
		
		position.x = Game.screen[0] + 300
		active = false
		cars = 8
		stopping = false
		started = false
