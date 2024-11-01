extends StageBase


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	default_zoom = 0.77
	bf_pos = Vector2(1800, 450)
	dad_pos = Vector2(700, 445)
	gf_pos = Vector2(1200, 430)
	
	bf_cam_offset.x = -200
	dad_cam_offset.x = 200
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
