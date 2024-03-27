extends Node2D

var flash = ColorRect.new()

var col_tween
var colors:Array[Color] = [Color(51, 255, 255), Color(54, 54, 204)]
var alphas:Array = [1, 0.64]
var to:bool = false
func _ready():
	flash.color = Color.WHITE
	flash.position = Vector2(-25, -15)
	flash.size = Vector2(1300, 755)
	#col_tween.create_tween()
	#col_tween.tween_property(self, "modulate", colors[0], 0.2)
	#col_tween.tween_property(self, "modulate:a", 1, 0.2)
	
	Conductor.bpm = 102
	Conductor.played_audio = true
	Conductor.inst = GlobalMusic.Player

var danced:bool = false
func beat_hit():
	$Funkin.scale = Vector2(1.1, 1.1)

	danced = !danced
	$TitleGF.play('dance'+ ('Left' if danced else 'Right'))
	$TitleGF.frame = 0

var accepted:bool = false
var funk_sin:float = 0
func _process(delta):
	funk_sin += delta
	$Funkin.rotation = sin(funk_sin * 2) / 8
	$Funkin.scale.x = lerpf($Funkin.scale.x, 1, delta * 7)
	$Funkin.scale.y = $Funkin.scale.x
	
	Conductor.song_pos = GlobalMusic.pos #im lazy dont judge me
	if Input.is_action_just_pressed("Accept") and !accepted:
		accepted = true
		add_child(flash)
		
		var out = create_tween()
		out.tween_property(flash, 'modulate:a', 0, 1)
		GlobalMusic.play_sound('confirmMenu')
		
		await get_tree().create_timer(1).timeout
		Game.switch_scene('menus/main_menu')
		Conductor.reset()

func on_music_finish():
	Conductor.soft_reset()
