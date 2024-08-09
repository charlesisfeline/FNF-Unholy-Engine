extends Node2D

@onready var order = FileAccess.open('res://assets/data/weeks/week-order.txt', FileAccess.READ).get_as_text().split('\n')

var weeks:Array[Sprite2D] = []
func _ready():
	#for i in order: weeks.append(i.strip_edges())
	
	#for file in order: # base songs first~
		#var week_file = JsonHandler.parse_week(file)
		#var d_list = week_file.difficulties if week_file.has('difficulties') else []
		#for song in week_file.songs:
			#add_song(FreeplaySong.new(song, d_list))
			
	for i in 8:
		var new_week = Sprite2D.new()
		new_week.texture = load('res://assets/images/story_mode/weeks/'+ ('tutorial' if i == 0 else 'week'+str(i)) +'.png')
		#new_week.y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed('back'):
		Game.switch_scene('menus/main_menu')

class StoryItem extends Sprite2D:
	func _init():
		pass
