extends CanvasLayer

signal finished(part:int) # 0 is trans out, 1 is trans in
var tween

const hole_images:Array[String] = ['circle', 'icon', 'skry', 'note']
@onready var hole = $Group/Hole
@onready var black = $Group/Black
var on_finish:Callable = func(): 
	#Game.scene.paused = false
	Game.remove_child(self)
	queue_free()

func trans_in(speed:float = 0.7, call_func:bool = false):
	hole.scale = Vector2(0, 0)
	start()
	
	tween.tween_property(hole, 'scale', Vector2(15, 15), speed)
	await tween.finished
	finished.emit(1)
	
	if call_func:
		on_finish.call()

func trans_out(speed:float = 0.7, call_func:bool = false):
	hole.scale = Vector2(15, 15)
	start()
	
	tween.tween_property(hole, 'scale', Vector2(0, 0), speed)
	await tween.finished
	finished.emit(0)
	
	if call_func:
		on_finish.call()
	
func start():
	#Game.scene.paused = true
	var new_tex:String = hole_images.pick_random()
	hole.texture = load('res://assets/images/ui/transitions/'+ new_tex +'.png') # funny random
	#if new_tex == 'note': 
	#	hole.rotation = deg_to_rad([0, 90, 180, 270].pick_random())
	#else: 
	#	hole.rotation = 0
	#	offset.y = 0
	if tween: tween.kill()
	tween = create_tween()

	Game.center_obj(hole)
	black.scale = Vector2(1300, 730)
	black.position = Vector2(Game.screen[0] / 2, Game.screen[1] / 2)
