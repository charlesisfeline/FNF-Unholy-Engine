class_name StageBase extends Node2D

# things all stages will have
var default_zoom:float = 0.8
var cam_speed:float = 4

var beat:int:
	get: return Conductor.cur_beat
var step:int:
	get: return Conductor.cur_step
var section:int:
	get: return Conductor.cur_section

var boyfriend:Character:
	get: return Game.scene.boyfriend
var dad:Character:
	get: return Game.scene.dad
var gf:Character:
	get: return Game.scene.gf

var dad_pos:Vector2 = Vector2(0, 0)
var gf_pos:Vector2 = Vector2(0, 0)
var bf_pos:Vector2 = Vector2(0, 0)

func _ready():
	pass # Replace with function body.
