extends StageBase

var flash:ColorRect
func _ready():
	default_zoom = 1.05
	
	flash = ColorRect.new()
	flash.modulate.a = 0
	add_child(flash)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

var lightning_beat:int = 0
var lighting_offset:int = 8
func beat_hit():
	if Game.rand_bool(10) and beat > lightning_beat + lighting_offset:
		strike()

func strike():
	lightning_beat = beat
	lighting_offset = randi_range(8, 24)
	flash.modulate.a = 0.4
	create_tween().tween_property(flash, 'modulate:a', 0.5, 0.075)
	create_tween().tween_property(flash, 'modulate:a', 0, 0.25).set_delay(0.15)
		
	GlobalMusic.play_sound('thunder_'+ str(randi_range(1, 2)))
	$BG.play('strike')
	boyfriend.play_anim('scared', true)
	gf.play_anim('scared', true)
