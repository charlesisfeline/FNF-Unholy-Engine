class_name UI; extends CanvasLayer;

signal countdown_start
signal countdown_tick(tick:int) # 0 = 'three', 1 = 'two', 2 = 'one', 3 = 'go', 4 = song start
signal song_start # technically countdown tick 4 is song start but why would you use that smh

# probably gonna move some note shit in here
@onready var score_txt:Label = $Score_Txt
@onready var time_bar:HealthBar = $TimeBar
@onready var health_bar:HealthBar = $HealthBar
@onready var icon_p1:Icon = $HealthBar/IconP1
@onready var icon_p2:Icon = $HealthBar/IconP2
@onready var mark:Sprite2D = $HealthBar/Mark

@onready var ms_txt:Label = $Strum_Group/Player/HitTime
@onready var player_group:Strum_Line = $Strum_Group/Player
@onready var opponent_group:Strum_Line = $Strum_Group/Opponent
var gf_group:Strum_Line

@onready var player_strums:Array = player_group.get_strums()
@onready var opponent_strums:Array = opponent_group.get_strums()
var gf_strums:Array
var strums:Array[Strum] = []
var chart_notes = []

var characters:Array[Character] = []

var SKIN = SkinInfo.new()
var cur_skin:String = 'default':
	set(new_style): 
		if new_style != cur_skin:
			cur_skin = new_style
			change_skin(new_style)
			
var finished_countdown:bool = false
var countdown_spr:Array[String] = ['ready', 'set', 'go']
var sounds:Array[String] = ['intro3', 'intro2', 'intro1', 'introGo']

var total_hit:float = 0
var note_percent:float = 0
var accuracy:float = -1
var hit_count:Dictionary = {'epic': 0, 'sick': 0, 'good': 0, 'bad': 0, 'shit': 0, 'miss': 0}
var fc:String = 'N/A'

var def_mark_scale:Vector2 = Vector2(0.7, 0.7)
var zoom:float = 1:
	set(new_zoom):
		zoom = new_zoom
		scale = Vector2(zoom, zoom)

func _ready():
	time_bar.fill_mode = 0
	time_bar.set_colors(Color(0, 0, 0.5), Color(0.25, 0.65, 0.95))
	
	strums.append_array(opponent_strums)
	strums.append_array(player_strums)
	
	var downscroll = Prefs.scroll_type == 'down'
	var middscroll = Prefs.scroll_type == 'middle' # funny
	#var spltscroll = Prefs.splitscroll
	
	# i am stupid they are a group i dont have to set the strums position manually just the group y pos
	player_group.position.y = 560 if downscroll else 55
	opponent_group.position.y = 560 if downscroll else 55
	
	for i in strums: i.downscroll = downscroll
	
	var can_center:bool = Prefs.center_strums
	match Prefs.scroll_type:
		'middle':
			can_center = true
			var lol = [180, 90, 270, 0]
			for i in player_strums.size():
				player_strums[i].scroll = lol[i]
		'left', 'right':
			can_center = false
			var scr:Array[int] = [0, 180]
			var x_pos:Array = [Game.screen[0] / 2, Game.screen[0] / 2]
			if Prefs.scroll_type == 'right': 
				scr.reverse()
				x_pos = [Game.screen[0] - 120, 120]
				opponent_group.modulate = Color(0.2, 0.2, 0.2, 0.4)
			
			player_group.position = Vector2(x_pos[0] + 60, 200)
			opponent_group.position = Vector2(x_pos[1] - 60, 200)
			
			for i in strums.size():
				strums[i].position = Vector2(0, 110 * strums[i].dir)
				strums[i].scroll = scr[(0 if i > 3 else 1)]
			
		'split':
			health_bar.scale.x = 0.8
			for i in strums.size():
				if (strums[i].dir > 1 and i > 3) or (i <= 3 and strums[i].dir < 2):
					strums[i].scroll = -strums[i].scroll
					strums[i].position.y = 560
		
	if can_center:
		time_bar.position.x = 214
		player_group.position.x = (Game.screen[0] / 2) - 180
		if Prefs.scroll_type == 'middle':
			player_group.position.y = (Game.screen[1] / 2) - 55
			
		opponent_group.modulate.a = 0.4
		opponent_group.scale = Vector2(0.7, 0.7)
		opponent_group.z_index = -1
		opponent_group.position = Vector2(60, 400 if downscroll else 300)
	
	health_bar.position.x = (Game.screen[0] / 2.0) # 340
	health_bar.position.y = 85 if downscroll else 630
	health_bar.z_index = -2
	icon_p1.follow_spr = health_bar
	icon_p2.follow_spr = health_bar
	
	time_bar.position.y = 618 if downscroll else 110
	score_txt.position.x = (Game.screen[0] / 2) - (score_txt.size[0] / 2)
	if downscroll:
		score_txt.position.y = 130
		
	mark.texture = load('res://assets/images/ui/skins/'+ cur_skin +'/auto.png')
	mark.scale = SKIN.strum_scale
	
	#player_group.scale = Vector2(0.9, 0.9)
	#opponent_group.scale = Vector2(0.9, 0.9)
	#player_group.position.x += 80
	#opponent_group.position.x -= 30
	
	#gf_group = load('res://game/objects/ui/strum_line.tscn').instantiate()
	#add_child(gf_group)
	#gf_group.scale = Vector2(0.9, 0.9)
	#gf_group.position = Vector2((Game.screen[0] / 2.0) - 170, 55)
	#gf_strums = gf_group.get_strums()
	
	#mark.position = health_bar.position + Vector2(330, -5)
	#mark.z_index = -2

var hp:float = 50.0:
	set(val): hp = clampf(val, 0, 100)
	
func _process(delta):
	if finished_countdown:
		time_bar.value = (abs(Conductor.song_pos / Conductor.song_length) * 100.0)
		$Elasped.text = str(Game.to_time(floor(Conductor.song_pos / Conductor.playback_rate)))
		$Left.text = str(Game.to_time(abs(floor((Conductor.song_length - Conductor.song_pos) / Conductor.playback_rate))))

	$Elasped.position = time_bar.position - Vector2($Elasped.size.x / 2, 30)
	$Left.position = time_bar.position - Vector2($Left.size.x / 2, -10)
		
	health_bar.value = lerpf(health_bar.value, hp, delta * 8)

	mark.scale = lerp(mark.scale, def_mark_scale, delta * 10)
	
	offset.x = (scale.x - 1.0) * -(Game.screen[0] * 0.5)
	offset.y = (scale.y - 1.0) * -(Game.screen[1] * 0.5)
	
func update_score_txt() -> void:
	if Game.scene.get('score') != null:
		var stuff = [Game.scene.score, get_acc(), Game.scene.misses]
		score_txt.text = 'Score: %s / Accuracy: [%s] \\ Misses: %s' % stuff
	#$Tally.text = '
	#[color=purple]Epics: '+ str(hit_count['epic']) +'
	#[color=cyan]Sicks: '+ str(hit_count['sick']) +'
	#[color=green]Goods: '+ str(hit_count['good']) +'
	#[color=yellow]Bads: '+ str(hit_count['bad']) +'
	#[color=red]Shits: '+ str(hit_count['shit'])

func get_acc() -> String:
	var new_acc = clampf(note_percent / total_hit, 0, 1)
	if is_nan(new_acc): return '?'
	accuracy = Game.round_d(new_acc * 100, 2)
	fc = get_fc()
	return str(accuracy) +'% - '+ fc 
	
func get_fc() -> String:
	if hit_count['miss'] == 0: # dumb
		var da_fc:String = 'FC'
		if hit_count['bad'] + hit_count['shit'] == 0:
			if hit_count['epic'] > 0: da_fc = 'EFC'
			if hit_count['sick'] > 0: da_fc = 'SFC'
			if hit_count['good'] > 0: da_fc = 'GFC'
		return da_fc
	if hit_count['miss'] in range(1, 10):
		return 'SDCB'
	return 'Clear'
	
func reset_stats() -> void:
	fc = 'N/A'
	total_hit = 0
	note_percent = 0
	accuracy = -1
	for i in hit_count.keys():
		hit_count[i] = 0
	
	update_score_txt()

func add_to_strum_group(item:Variant, strums:String = 'player') -> void:
	if item == null: return
	var group = get(strums +'_group')
	if group == null: group = player_group
	group.add_child(item)

func add_behind(item) -> void:
	$Back.add_child(item) 
	item.z_index = -1
	#move_child(item, 0) #layering would get fucked

func change_skin(new_skin:String = 'default') -> void: # change style of whole hud, instead of one by one
	cur_skin = new_skin
	SKIN.load_skin(new_skin)
	
	player_group.set_all_skins(new_skin)
	opponent_group.set_all_skins(new_skin)
	#for strum in strums: strum.load_skin(new_skin)
	for note in Game.scene.notes: 
		note.load_skin(new_skin)
		
	mark.texture = load('res://assets/images/ui/skins/'+ cur_skin +'/auto.png')
	mark.texture_filter = Game.get_alias(SKIN.antialiased)
	def_mark_scale = (SKIN.strum_scale if SKIN.strum_scale.x <= 0.7 else SKIN.strum_scale / 1.5)
	mark.scale = def_mark_scale

var count_down:Timer
var times_looped:int = -1

func start_countdown(from_beginning:bool = false) -> void:
	if from_beginning:
		countdown_start.emit()
		finished_countdown = false
		Conductor.song_pos = -(Conductor.crochet * 5.0)
		count_down = Timer.new() # get_tree.create_timer starts automatically and isn't reusable
		add_child(count_down)
	
	count_down.start((Conductor.crochet / 1000.0) / Conductor.playback_rate)
	await count_down.timeout
	times_looped += 1
	countdown_tick.emit(times_looped)

	if times_looped < 4:
		if times_looped > 0:
			var spr = Sprite2D.new()
			spr.texture = load('res://assets/images/ui/skins/'+ cur_skin +'/'+ countdown_spr[times_looped - 1] +'.png')
			add_child(spr)
			spr.scale = SKIN.countdown_scale
			spr.texture_filter = Game.get_alias(SKIN.antialiased)
			Game.center_obj(spr)
			
			var tween = create_tween().tween_property(spr, 'modulate:a', 0, Conductor.crochet / 1000)
			tween.finished.connect(spr.queue_free)
		Audio.play_sound(sounds[times_looped], 1, true)
		start_countdown()
	else:
		stop_countdown()
		song_start.emit()

func stop_countdown() -> void:
	finished_countdown = true
	times_looped = -1
	if count_down != null:
		remove_child(count_down)
		count_down.queue_free()
