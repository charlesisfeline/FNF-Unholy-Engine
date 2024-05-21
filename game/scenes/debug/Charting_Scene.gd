extends Node2D

var total_notes = []

var loaded_notes:Dictionary = {
	last = [], curr = [], next = []
}
func _ready():
	for i in 144: 
		var the = ColorRect.new()
		the.custom_minimum_size = Vector2(40, 40)
		the.modulate = Color.DIM_GRAY if i % 2 == 0 else Color.DARK_GRAY
		$NoteGrid.add_child(the)
		
	for note in JsonHandler.chart_notes:
		var new_note = Note.new(NoteData.new(note))
		add_child(new_note)
		new_note.position = Vector2(100 * new_note.dir, 0)
		total_notes.append(new_note)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("back"):
		Game.switch_scene('Play_Scene')
	
	for note in total_notes:
		note.position.y = (note.strum_time / 0.45) + 50
	
