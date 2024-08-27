class_name BasicNote; extends Node2D;
# a very simple note for the chart editor, without all the other shit

const COLORS:Array[String] = ['purple', 'blue', 'green', 'red']

var style:StyleInfo = StyleInfo.new()
var tex_path:String = 'assets/images/ui/styles/%s/notes/'
var antialiasing:bool = true:
	get: return texture_filter == CanvasItem.TEXTURE_FILTER_LINEAR
	set(alias):
		antialiasing = alias
		texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR if alias else CanvasItem.TEXTURE_FILTER_NEAREST

var width:float = 0.0:
	get:
		if is_sustain:
			return sustain.texture.get_width() * abs(hold_group.scale.x)
		return note.texture.get_width() * abs(scale.x)
var height:float = 0.0:
	get:
		if is_sustain:
			return sustain.texture.get_height() * abs(hold_group.scale.y)
		return note.texture.get_height() * abs(scale.y)
	
var spawned:bool = false
var strum_time:float
var dir:int
var visual_dir:int # for keeping player notes on right and opp on left
var true_dir:int   # the actual direction the note is

var was_hit:bool = false # for normal notes
var hitting:bool = false # for sustains

var must_press:bool = false

var is_sustain:bool = false
var length:float = 0.0
var offset_y:float = 0.0

var type:String = "":
	set(new_type):
		if new_type.is_empty(): return
		match new_type.to_lower():
			'alt animation', 'alt', 'true': 
				type = 'Alt'
			'no animation':
				type = 'No Anim'
			'gf sing':
				type = 'GF'
			'hurt note', 'markov note':
				type = 'Hurt'
				modulate = Color.BLACK
			_:
				type = new_type

var note
var sustain:TextureRect
var end:TextureRect = TextureRect.new()
var hold_group:Control = Control.new()

var parent:BasicNote

var alpha:float = 1:
	get: return modulate.a
	set(alpha): modulate.a = alpha

var label:Label = Label.new()
var text:String:
	get: return label.text
	set(txt): label.text = txt
	
func _init(data = null, sustain:bool = false, in_chart:bool = false):
	if data != null:
		if data is Array: data = NoteData.new(data)
		copy_from(data)
		if sustain:
			is_sustain = true
			parent = data
		else:
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		
			label.add_theme_font_override('font', load('res://assets/fonts/vcr.ttf'))
			label.add_theme_font_size_override('font_size', 20)
			label.add_theme_constant_override('outline_size', 5)
			label.scale *= 5

func _ready():
	spawned = true
	tex_path = tex_path % [style.style]
	antialiasing = style.antialiased
	position = Vector2(INF, -INF) #you can see it spawn in for a frame or two
	
	if is_sustain:
		alpha = 0.6
		# stole from fnf raven because i didnt know how "Control"s worked
		hold_group.clip_contents = true

		add_child(hold_group)
		move_child(hold_group, 0)
		
		end = TextureRect.new()
		end.texture = load(tex_path + COLORS[dir] +'_end.png')

		end.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
		end.grow_horizontal = Control.GROW_DIRECTION_BOTH
		end.grow_vertical = Control.GROW_DIRECTION_BEGIN
		
		sustain = TextureRect.new()
		sustain.texture = load(tex_path + COLORS[dir] +'_hold.png')
		
		sustain.set_anchors_preset(Control.PRESET_FULL_RECT)
		sustain.set_anchor_and_offset(SIDE_BOTTOM, 1.0, -end.texture.get_height())
		sustain.grow_horizontal = Control.GROW_DIRECTION_BOTH
		sustain.grow_vertical = Control.GROW_DIRECTION_BOTH
		
		hold_group.add_child(sustain)
		hold_group.add_child(end)
	else:
		note = Sprite2D.new()
		note.texture = load(tex_path + COLORS[dir] +'.png')

		add_child(note)
		
		add_child(label)
		text = type.replace('Note', '')
		label.position -= Vector2(label.size.x * (30 * label.get_total_character_count()), -label.size.y * 1.5)
		
func _process(delta):
	if !spawned: return
	was_hit = strum_time <= Conductor.song_pos

	if is_sustain:
		hitting = was_hit and strum_time + length > Conductor.song_pos

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

func resize_hold(update_control:bool = false, to_size:float = 0.0) -> void:
	if !spawned: return
	hold_group.size.y = to_size
	#var rounded_scale = Game.round_d(style.note_scale.y, 1)
	#if rounded_scale > 0.7: 
	#	hold_group.size.y /= (rounded_scale + (rounded_scale / 2))
	
	#if update_control:
	#	sustain.set_anchor_and_offset(SIDE_BOTTOM, 1.0, -end.texture.get_height())
	#	hold_group.size.x = maxf(end.texture.get_width(), sustain.texture.get_width())
	#	hold_group.position.x = 0 - hold_group.size.x * 0.5

func copy_from(item) -> void:
	if item != null and (item is BasicNote or item is NoteData):
		strum_time = item.strum_time
		dir = item.dir
		length = item.length
		must_press = item.must_press
		
		type = item.type
