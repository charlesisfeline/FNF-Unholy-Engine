extends StageBase

var windows:Array = [ # window colors so fancy wow woah woaoh
	[49, 162, 253], [49, 253, 140], [251, 51, 245], [253, 69, 49], [251, 166, 51]
]

var train:Train = Train.new(Vector2(2000, 360))
func _ready():
	default_zoom = 1.05
	
	bf_pos += Vector2(70, -50)
	dad_pos += Vector2(100, -50)
	add_child(train)
	move_child(train, 4)

func _process(delta):
	$Windows/Sprite.self_modulate.a -= (Conductor.crochet / 1000) * delta * 1.5

func beat_hit(beat:int):
	train.beat_hit(beat)
	if beat % 4 == 0:
		var cur_col = windows[randi_range(0, windows.size() - 1)]
		$Windows/Sprite.self_modulate = Color(cur_col[0] / 255.0, cur_col[1] / 255.0, cur_col[2] / 255.0, 1)
	
class Train extends Sprite2D:
	var active:bool = false
	var started:bool = false
	var stopping:bool = false
	
	var frame_limit:float = 0.0
	var sound = AudioStreamPlayer.new()
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
					Game.scene.gf.idle_suffix = '-hair' #play_anim('hairBlow')
					#Game.scene.gf.special_anim = true
				if started:
					position.x -= 400
					if position.x < -2000 && !stopping:
						position.x = -1150
						cars -= 1
						if cars < 1:
							stopping = true
					
					if position.x < -4000 && stopping:
						restart()
				
	func beat_hit(beat:int):
		if !active:
			cooldown += 1

		if beat % 8 == 4 && Game.rand_bool(30) && !active && cooldown > 8:
			cooldown = randi_range(-4, 0)
			active = true
			sound.play(0)
				
	func restart() -> void:
		Game.scene.gf.idle_suffix = ''
		Game.scene.gf.play_anim('hairFall')
		Game.scene.gf.special_anim = true
		#Game.scene.gf.danced = Game.scene.gf.danced
		
		
		position.x = Game.screen[0] + 300
		active = false
		cars = 8
		stopping = false
		started = false
