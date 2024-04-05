class_name UI; extends CanvasLayer;

@onready var cur_scene = get_tree().current_scene
@onready var score_txt:Label = $Score_Txt
@onready var health_bar:TextureProgressBar = $HealthBar
@onready var icon_p1:Sprite2D = $HealthBar/IconP1
@onready var icon_p2:Sprite2D = $HealthBar/IconP2

@onready var player_strums:Array = $Strum_Group/Player.get_strums()
@onready var opponent_strums:Array = $Strum_Group/Opponent.get_strums()
var strums:Array = []

var total_hit:float = 0
var hit_count:Dictionary = {'sick': 0, 'good': 0, 'bad': 0, 'shit': 0}

func _ready():
	strums.append_array(opponent_strums)
	strums.append_array(player_strums)
	
	var downscroll = Prefs.get_pref('downscroll') 
	#var middscroll = Prefs.get_pref('middlescroll')
	#var spltscroll = Prefs.get_pref('splitscroll')
	
	for i in strums: # i can NOT be bothered to position these mfs manually
		#var play = i < 4
		#var cur_strum:Strum = strums[i]
		#cur_strum.dir = (i % 4)
		#cur_strum.position.x = 150 / (1.5 if play else 0.45)
		#cur_strum.position.x += (110 * i)
		i.position.y = 560 if downscroll else 55
		#cur_strum.is_player = (i > 3)
	icon_p1.change_icon('bf', true)
	icon_p2.change_icon('dad')
	
	health_bar.position.x = (Game.screen[0] / 2.0) - (health_bar.texture_under.get_width() / 2.0) # 340
	health_bar.position.y = 85 if downscroll else 630
	icon_p1.follow_spr = health_bar
	icon_p2.follow_spr = health_bar
	
	score_txt.position.x = (Game.screen[0] / 2) - (score_txt.size[0] / 2)
	if downscroll:
		score_txt.position.y = 130

var hp:float = 50:
	set(val): hp = min(max(val, health_bar.min_value), health_bar.max_value)
func _process(delta):
	health_bar.value = lerpf(health_bar.value, hp, delta * 7)

func update_score_txt():
	score_txt.text = 'Score: %s - Misses: %s' % [cur_scene.score, cur_scene.misses]

func add_to_strum_group(item = null, to_player:bool = true):
	if item == null: return
	if to_player:
		$Strum_Group/Player.add_child(item)
	else:
		$Strum_Group/Opponent.add_child(item)

func add_behind(item):
	$Back.add_child(item)
	
#func swap_group(item):
#	pass
