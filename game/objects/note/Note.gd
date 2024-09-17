class_name Note; extends Node2D;

var style:StyleInfo:
	get: return Game.scene.ui.STYLE if Game.scene.has_node('UI') else StyleInfo.new()
var tex_path:String = 'assets/images/ui/styles/%s/notes/'
var antialiasing:bool = true:
	get: return texture_filter == CanvasItem.TEXTURE_FILTER_LINEAR
	set(alias):
		antialiasing = alias
		texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR if alias else CanvasItem.TEXTURE_FILTER_NEAREST

var width:float = 0:
	get:
		if is_sustain:
			return sustain.texture.get_width() * abs(hold_group.scale.x)
		return note.texture.get_width() * abs(scale.x)
var height:float = 0:
	get:
		if is_sustain:
			return sustain.texture.get_height() * abs(hold_group.scale.y)
		return note.texture.get_height() * abs(scale.y)
	
const COLORS:Array[String] = ['purple', 'blue', 'green', 'red']

var chart_note:bool = false
var spawned:bool = false
var strum_time:float
var dir:int = 0

var must_press:bool = false
var speed:float = 1.0:
	set(new_speed): 
		speed = new_speed
		if is_sustain: resize_hold()
		
var alt:String = ""
var gf:bool = false
var no_anim:bool = false
var unknown:bool = false
var type:String = "":
	set(new_type):
		if (new_type.is_empty() or new_type == '0') and type.is_empty(): return
		match new_type.to_lower().strip_edges():
			'alt animation', 'true': new_type = 'Alt'
			'no animation': new_type = 'No Anim'
			'gf sing': new_type = 'GF'
			'hurt note', 'markov note': new_type = 'Hurt'
			'hey!': new_type = 'Hey'
	
		type = new_type
		match new_type:
			'Hey': pass
			'Alt': alt = '-alt'
			'No Anim': no_anim = true
			'GF': gf = true
			'Hurt':
				should_hit = false
				early_mod = 0.5
				late_mod = 0.5
				modulate = Color.BLACK
			_:
				unknown = true
				modulate = Color.GRAY



var should_hit:bool = true
var can_hit:bool = false#:
#	get: return (must_press and strum_time >= Conductor.song_pos - (Conductor.safe_zone * 0.8)\
#	and strum_time <= Conductor.song_pos + (Conductor.safe_zone * 1))

var early_mod:float = 0.8
var late_mod:float = 1.0
var rating:String = ''
var was_good_hit:bool = false#:
#	get: return not must_press and strum_time <= Conductor.song_pos
var too_late:bool = false

var is_sustain:bool = false
var length:float = 0.0
var temp_len:float = 0.0 #if you dont immediately hold
var offset_y:float = 0.0
var parent:Note

var holding:bool = false
var min_len:float = 25.0 # before a sustain is counted as "hit"
var dropped:bool = false:
	set(drop): 
		dropped = drop
		if dropped: 
			modulate = Color(0.75, 0.75, 0.75, 0.4)

var note:Sprite2D
var sustain:TextureRect
var end:TextureRect
var hold_group:Control

var alpha:float = 1.0:
	get: return modulate.a
	set(alpha): modulate.a = alpha

func _init(data = null, sustain:bool = false, in_chart:bool = false):
	if data != null:
		copy_from(data)
		chart_note = in_chart
		if sustain and data is Note:
			is_sustain = true
			temp_len = length
			parent = data

func _ready():
	spawned = true
	tex_path = tex_path % [style.style]
	antialiasing = style.antialiased
	position = Vector2(INF, -INF) #you can see it spawn in for a frame or two
	scale = style.note_scale
	
	if is_sustain:
		alpha = 0.6
		# stole from fnf raven because i didnt know how "Control"s worked
		hold_group = Control.new()
		hold_group.clip_contents = true

		add_child(hold_group)
		move_child(hold_group, 0)
		
		end = TextureRect.new()
		end.texture = load(tex_path + COLORS[dir] +'_end.png')
		if !chart_note: end.stretch_mode = TextureRect.STRETCH_TILE
		end.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
		end.grow_horizontal = Control.GROW_DIRECTION_BOTH
		end.grow_vertical = Control.GROW_DIRECTION_BEGIN
		
		sustain = TextureRect.new()
		sustain.texture = load(tex_path + COLORS[dir] +'_hold.png')
		if !chart_note: sustain.stretch_mode = TextureRect.STRETCH_TILE # hmm
		sustain.set_anchors_preset(Control.PRESET_FULL_RECT)
		sustain.set_anchor_and_offset(SIDE_BOTTOM, 1.0, -end.texture.get_height() + 1.0)
		sustain.grow_horizontal = Control.GROW_DIRECTION_BOTH
		sustain.grow_vertical = Control.GROW_DIRECTION_BOTH
		
		hold_group.add_child(sustain)
		hold_group.add_child(end)
		
		if !chart_note:
			resize_hold(true)
			if Prefs.downscroll: hold_group.scale.y = -1
			if Prefs.behind_strums: hold_group.z_index = -1
	else:
		note = Sprite2D.new()
		note.texture = load(tex_path + COLORS[dir] +'.png')
		add_child(note)
		
		if unknown:
			var lol = Alphabet.new('?')
			lol.position.x -= 22
			lol.position.y -= 30
			add_child(lol)
			lol.z_index = 3
		

func _process(delta):
	var safe_zone:float = Conductor.safe_zone
	if chart_note: return
	if is_sustain:
		if strum_time <= Conductor.song_pos:
			can_hit = true #!dropped
			#if dropped: return
			# strum_time <= Conductor.song_pos and strum_time + length > Conductor.song_pos:
			temp_len -= (1000 * delta) * Conductor.playback_rate
			#offset_y -= 1000 * delta
			if !must_press: holding = true
			
			if holding and length != temp_len: #end piece kinda fucks off a bit every now and then
				length = temp_len
				resize_hold()
				
				if roundi(length) <= min_len:
					was_good_hit = true
	else:
		if must_press:
			can_hit = (strum_time > Conductor.song_pos - (safe_zone * late_mod) && \
				strum_time < Conductor.song_pos + (safe_zone * early_mod));
		
			if strum_time < Conductor.song_pos - safe_zone and !was_good_hit:
				too_late = true
		else:
			can_hit = false
			was_good_hit = strum_time <= Conductor.song_pos

func follow_song_pos(strum:Strum) -> void:
	if is_sustain and holding: 
		position.y = strum.position.y
		return
		
	var pos:float = (0.45 * (Conductor.song_pos - strum_time) * speed) #/ Conductor.playback_rate# + offset_y
	if !strum.downscroll: pos *= -1
	
	position.x = strum.position.x
	position.y = strum.position.y + pos
	if !is_sustain:
		rotation = strum.rotation

func load_skin(skin) -> void:
	tex_path = 'res://assets/images/ui/styles/'+ skin.style +'/notes/'+ COLORS[dir]
	antialiasing = skin.antialiased
	scale = skin.note_scale

	if is_sustain:
		scale.y = 0.7
		sustain.texture = load(tex_path +'_hold.png')
		end.texture = load(tex_path +'_end.png')
		resize_hold(true)
	else:
		note.texture = load(tex_path +'.png')

func resize_hold(update_control:bool = false) -> void:
	if !spawned: return
	hold_group.size.y = ((length * 0.63) * speed)
	var rounded_scale = Game.round_d(style.note_scale.y, 1)
	if rounded_scale > 0.7: 
		hold_group.size.y /= (rounded_scale + (rounded_scale / 2))
	
	if update_control:
		sustain.set_anchor_and_offset(SIDE_BOTTOM, 1.0, -end.texture.get_height() + 1.0)
		hold_group.size.x = maxf(end.texture.get_width(), sustain.texture.get_width())
		hold_group.position.x = 0 - hold_group.size.x * 0.5

func copy_from(item) -> void:
	if item != null and (item is Note or item is NoteData):
		strum_time = item.strum_time
		dir = item.dir
		length = item.length
		must_press = item.must_press
		type = item.type

class Event extends Note:
	func _init():
		note = Sprite2D.new()
		note.texture = load('res://assets/images/ui/event.png')
		add_child(note)
