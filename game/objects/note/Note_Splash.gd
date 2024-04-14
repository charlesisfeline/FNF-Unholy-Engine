extends AnimatedSprite2D

var strum
const col = ['purple', 'blue', 'green', 'red']
func _ready():
	scale = Vector2(0.95, 0.95)
	modulate.a = 0.6
	play('note impact '+ str(randi_range(1, 2)) +' '+ col[strum.dir])
	position = strum.position

func _process(delta):
	pass

func _on_animation_finished():
	#remove_child(self)
	queue_free()
