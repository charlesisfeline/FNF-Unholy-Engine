class_name UI; extends CanvasLayer;

var SPLASH = preload('res://game/objects/note/note_splash.tscn')
# probably gonna move some note shit in here
@onready var cur_scene = get_tree().current_scene
@onready var score_txt:Label = $Score_Txt
@onready var health_bar:TextureProgressBar = $HealthBar
@onready var icon_p1:Sprite2D = $HealthBar/IconP1
@onready var icon_p2:Sprite2D = $HealthBar/IconP2

@onready var player_strums:Array = $Strum_Group/Player.get_strums()
@onready var opponent_strums:Array = $Strum_Group/Opponent.get_strums()
var strums:Array = []

var style:String = 'default'
var countdown_spr:Array[String] = ['ready', 'set', 'go']

var total_hit:float = 0
var hit_count:Dictionary = {'sick': 0, 'good': 0, 'bad': 0, 'shit': 0}
var zoom:float = 1:
	set(new_zoom):
		zoom = new_zoom
		scale = Vector2(zoom, zoom)

func _ready():
	strums.append_array(opponent_strums)
	strums.append_array(player_strums)
	
	var downscroll = Prefs.downscroll
	#var middscroll = Prefs.middlescroll
	#var spltscroll = Prefs.splitscroll
	
	for i in strums: # i can NOT be bothered to position these mfs manually
		#var play = i < 4
		#var cur_strum:Strum = strums[i]
		#cur_strum.dir = (i % 4)
		#cur_strum.position.x = 150 / (1.5 if play else 0.45)
		#cur_strum.position.x += (110 * i)
		i.position.y = 560 if downscroll else 55
		i.downscroll = downscroll
		#cur_strum.is_player = (i > 3)
	#icon_p1.change_icon('bf', true)
	#icon_p2.change_icon('dad')
	
	health_bar.position.x = (Game.screen[0] / 2.0) - (health_bar.texture_under.get_width() / 2.0) # 340
	health_bar.position.y = 85 if downscroll else 630
	icon_p1.follow_spr = health_bar
	icon_p2.follow_spr = health_bar
	
	score_txt.position.x = (Game.screen[0] / 2) - (score_txt.size[0] / 2)
	if downscroll:
		score_txt.position.y = 130

var hp:float = 50:
	set(val): hp = clampf(val, health_bar.min_value, health_bar.max_value)
func _process(delta):
	health_bar.value = lerpf(health_bar.value, hp, delta * 7)
	offset.x = (scale.x - 1.0) * -(Game.screen[0] * 0.5)
	offset.y = (scale.y - 1.0) * -(Game.screen[1] * 0.5)
	
func update_score_txt():
	score_txt.text = 'Score: %s - Misses: %s' % [cur_scene.score, cur_scene.misses]

func spawn_splash(dir:int = 0):
	var new_splash = SPLASH.instantiate()
	new_splash.strum = player_strums[dir]
	add_to_strum_group(new_splash, true)
	await new_splash.animation_finished
	$Strum_Group/Player.remove_child(new_splash)
	new_splash.queue_free()
	
func add_to_strum_group(item = null, to_player:bool = true):
	if item == null: return
	if to_player:
		$Strum_Group/Player.add_child(item)
	else:
		$Strum_Group/Opponent.add_child(item)

func add_behind(item):
	$Back.add_child(item)

var count_down:Timer
var times_looped:int = -1
var sounds:Array = ['intro3', 'intro2', 'intro1', 'introGo']
var images:Array = ['ready', 'set', 'go']
func start_countdown(from_beginning:bool = false):
	if from_beginning:
		Conductor.song_pos = -Conductor.crochet * 5
		count_down = Timer.new() # get_tree.create_timer starts automatically and isn't reusable
		add_child(count_down)
	
	count_down.start(Conductor.crochet / 1000)
	await count_down.timeout
	times_looped += 1
	
	if times_looped < 4:
		if times_looped > 0:
			var spr = Sprite2D.new()
			spr.texture = load('res://assets/images/ui/'+ images[times_looped - 1] +'.png')
			add_child(spr)
			Game.center_obj(spr)
			var tween = create_tween().tween_property(spr, 'modulate:a', 0, Conductor.crochet / 1000)
			tween.finished.connect(spr.queue_free)
		GlobalMusic.play_sound('ui/'+ style +'/'+ sounds[times_looped])
		start_countdown()
