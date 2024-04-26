class_name Note; extends Node2D;

var style:StyleInfo = Game.scene.ui.STYLE
var tex_path:String = 'assets/images/ui/styles/%s/notes/'
var antialiasing:bool = true:
	get: return texture_filter == CanvasItem.TEXTURE_FILTER_LINEAR
	set(alias):
		antialiasing = alias
		texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR if alias else CanvasItem.TEXTURE_FILTER_NEAREST
		
const col_array:Array[String] = ['purple', 'blue', 'green', 'red']

var spawned:bool = false
var strum_time:float
var dir:int = 0

var must_press:bool = false
var speed:float = 1:
	set(new_speed): 
		speed = new_speed
		if is_sustain: resize_hold()
		
var type:String = ""

var can_hit:bool = false#:
#	get: return (must_press and strum_time >= Conductor.song_pos - (Conductor.safe_zone * 0.8)\
#	and strum_time <= Conductor.song_pos + (Conductor.safe_zone * 1))
	
var was_good_hit:bool = false#:
#	get: return not must_press and strum_time <= Conductor.song_pos
var too_late:bool = false

var is_sustain:bool = false
var length:float = 0
var temp_len:float = 0 #if you dont immediately hold
var offset_y:float = 0
var parent:Note

var holding:bool = false
var min_len:float = 10
var dropped:bool = false:
	set(drop): 
		dropped = drop
		if dropped: 
			modulate = Color.GRAY
			alpha = 0.4

var note
var sustain:TextureRect
var end:TextureRect
var hold_group:Control

var alpha:float = 1:
	get: return modulate.a
	set(alpha): modulate.a = alpha

func _init(data = null, sustain:bool = false):
	if data != null:
		copy_from(data)
		is_sustain = (sustain) #and data.length >= 100) #if its too short then its no sustain
		if is_sustain and data is Note:
			temp_len = length
			parent = data

func _ready():
	spawned = true
	tex_path = tex_path % [style.style]
	antialiasing = style.antialiased
	position = Vector2(INF, -INF) #you can see it spawn in for a frame or two
	scale = style.note_scale
	
	if is_sustain:
		scale.y = 0.7
		alpha = 0.6
		# stole from fnf raven because i didnt know how "Control"s worked
		hold_group = Control.new()
		hold_group.clip_contents = true

		add_child(hold_group)
		move_child(hold_group, 0)
		
		end = TextureRect.new()
		end.texture = load(tex_path + col_array[dir] +'_end.png')
		end.stretch_mode = TextureRect.STRETCH_TILE
		end.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
		end.grow_horizontal = Control.GROW_DIRECTION_BOTH
		end.grow_vertical = Control.GROW_DIRECTION_BEGIN
		
		sustain = TextureRect.new()
		sustain.texture = load(tex_path + col_array[dir] +'_hold.png')
		#sustain.stretch_mode = TextureRect.STRETCH_TILE # hmm
		sustain.set_anchors_preset(Control.PRESET_FULL_RECT)
		sustain.set_anchor_and_offset(SIDE_BOTTOM, 1.0, -end.texture.get_height())
		sustain.grow_horizontal = Control.GROW_DIRECTION_BOTH
		sustain.grow_vertical = Control.GROW_DIRECTION_BOTH
		
		hold_group.size.x = maxf(end.texture.get_width(), sustain.texture.get_width())
		hold_group.position.x -= hold_group.size.x * 0.5
		hold_group.size.y = ((length * 0.63) * speed)

		hold_group.add_child(sustain)
		hold_group.add_child(end)
		
		if Prefs.downscroll: hold_group.scale.y = -1
		if Prefs.behind_strums: hold_group.z_index = -1
	else:
		note = Sprite2D.new()
		note.texture = load(tex_path + col_array[dir] +'.png')
		add_child(note)

func _process(delta):
	var safe_zone:float = Conductor.safe_zone
	if is_sustain:
		if strum_time <= Conductor.song_pos:
			can_hit = true #!dropped
			#if dropped: return

			temp_len -= 1000 * delta
			#offset_y -= 1000 * delta
			if !must_press: holding = true
			
			if holding and length != temp_len: #end piece kinda fucks off a bit every now and then
				length = temp_len
				#position.y = 560 if Prefs.downscroll else 55
				resize_hold()
				
				if length <= min_len:
					was_good_hit = true

				#end.scale.y -= 10 * delta * speed
				#if end.scale.y <= 0:
			#		end.scale.y = 0
			#	queue_free()

		#end.position = sustain.position
		#end.position.y += sustain.scale.y * 44

	else:
		if must_press:
			can_hit = (Conductor.song_pos - (safe_zone * 0.8) and strum_time <= Conductor.song_pos + (safe_zone * 1))
		
			if strum_time < Conductor.song_pos - safe_zone and !was_good_hit:
				too_late = true
		else:
			can_hit = false
			was_good_hit = strum_time <= Conductor.song_pos

func follow_song_pos(strum:Strum):
	if is_sustain and holding: 
		position.y = strum.position.y
		return
	var pos:float = (0.45 * (Conductor.song_pos - strum_time) * speed)# + offset_y
	if !strum.downscroll: pos *= -1
	
	position.x = strum.position.x
	position.y = strum.position.y + pos

func load_skin(skin):
	tex_path = 'res://assets/images/ui/styles/'+ skin.style +'/notes/'+ col_array[dir]
	antialiasing = skin.antialiased
	scale = skin.note_scale

	if is_sustain:
		scale.y = 0.7
		sustain.texture = load(tex_path +'_hold.png')
		end.texture = load(tex_path +'_end.png')
		resize_hold(true)
	else:
		note.texture = load(tex_path +'.png')

func resize_hold(update_control:bool = false):
	if !spawned: return
	hold_group.size.y = ((length * 0.63) * speed)
	if update_control:
		sustain.set_anchor_and_offset(SIDE_BOTTOM, 1.0, -end.texture.get_height())
		hold_group.size.x = maxf(end.texture.get_width(), sustain.texture.get_width())
		hold_group.position.x = 0 - hold_group.size.x * 0.5

func copy_from(item):
	if item != null and (item is Note or item is NoteData):
		strum_time = item.strum_time
		dir = item.dir
		length = item.length
		must_press = item.must_press
		type = item.type
