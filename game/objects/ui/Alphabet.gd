class_name Alphabet; extends Control;

## The way the text visually scrolls (If Alignment is CENTER, Scroll changes nothing)
enum Scroll {
	LEFT_TO_RIGHT = 1,
	CENTER = 0,
	RIGHT_TO_LEFT = -1
}
## The way the text lines up
enum Alignment {
	LEFT,
	CENTER,
	RIGHT
}

var all_letters:Array[Letter] = []
var color:Color = Color(0, 0, 0, 0):
	set(new):
		if all_letters.is_empty(): return
		for i in all_letters:
			i.modulate = new
		color = new
		
var width:float = 0.0
var height:float = 0.0
var spaces:int = 0
var rows:int = 0

var x_diff:int = 45
var y_diff:int = 65
@export var bold:bool = false
@export var text:String = '':
	set(new_txt):
		while all_letters.size() > 0:
			all_letters[0].queue_free()
			remove_child(all_letters[0])
			all_letters.remove_at(0)
		text = new_txt.replace("\\n", "\n")
		if bold: text = text.to_lower() #picky lil bitch
		make_text(text)

@export var is_menu:bool = false
@export var scroll_dir:Scroll = Scroll.LEFT_TO_RIGHT
#@export var alignment:Alignment = Alignment.LEFT
var lock:Vector2 = Vector2.INF
var target_y:int = 0
var screen_offset:int = 100
var spacing:Vector2 = Vector2(35, 150)

func _init(init_text:String = '', is_bold:bool = true):
	bold = is_bold
	if init_text.length() > 0:
		text = init_text
		
#var first_snap:bool = false
#func _ready() -> void:
	#position = Vector2((target_y * 35) + 100, (remap(target_y, 0, 1, 0, 1.1) * spacing) + (Game.screen[0] * 0.28))
	
func make_text(tx:String) -> void:
	all_letters.clear()
	var letters_made:Array[Letter] = []
	
	var sheet:SpriteFrames = load('res://assets/images/ui/alphabet/%s.res' % ['bold' if bold else 'normal'])

	var offsets = Vector2.ZERO
	width = 0
	height = 0
	
	var cur_loop:int = 0
	for i in tx.split():
		var is_space = (i == ' ')
		if is_space: spaces += 1
		if i == '\n': rows += 1
		
		if spaces != 0: offsets.x += (x_diff * spaces)
		spaces = 0
		
		if rows != 0:
			offsets.x = 0
			offsets.y += y_diff * rows
		rows = 0
		
		var anim = get_anim(i)
		var letter = Letter.new(offsets, i, cur_loop, rows)
		if anim != '' and is_instance_valid(sheet):
			var e:= sheet.get_frame_texture(anim, 0)
			var let:String = anim if e != null else "question"
			
			letter.char = anim # just in case
			letter.sprite_frames = sheet
			letter.centered = false
			letter.play(let)
			letter.offset = offset_letter(i) #Vector2.ZERO #true_offsets
			if !bold: letter.offset.y -= letter._height / 1.05
			offsets.x += letter._width
			
		letters_made.append(letter)
		cur_loop += 1
	
	name = 'Alphabet:'+ text
	for i in letters_made:
		if i.char != '': width += i._width
		add_child(i)
		all_letters.append(i)
	height = letters_made.back()._height
	letters_made.clear()
	color = Color.BLACK if !bold else Color.WHITE

func _process(delta):
	if is_menu:
		var remap_y:float = remap(target_y, 0, 1, 0, 1.1)
		#var x_pos:float = Game.screen[0] / 2.0 - width / 2.0
		#Vector2(((target_y * 35 * (remap_y * 5)) * scroll_dir) + 100,\
		var would_be = Vector2((target_y * spacing.x * scroll_dir) + screen_offset, (remap_y * spacing.y) + (Game.screen[0] * 0.28))
		var scroll:Vector2 = Vector2(
			lock.x if lock.x != INF else lerpf(position.x, would_be.x, (delta / 0.16)),
			lock.y if lock.y != INF else lerpf(position.y, would_be.y, (delta / 0.16))
		)
		#if first_snap:
		position = scroll
		#else:
		#	first_snap = true

func get_anim(item) -> String:
	item = item.dedent()
	match item:
		"{": return "(" if !bold else "{"
		"}": return ")" if !bold else "}"
		"[": return "(" if !bold else "["
		"]": return ")" if !bold else "]"
		"&": return "amp"
		"!": return "exclamation"
		"'": return "apostrophe"
		"?": return "question"
		_:
			if item == null or item == "" or item == "\n": return ""
			if !bold:
				if Letter.ALPHABET.find(item.to_lower()) != -1:
					var casing = (' upper' if item.to_lower() != item else ' lower') + 'case'
					return "%s".dedent() % [item.to_lower() + casing]
			return item.to_lower().dedent()

func offset_letter(item) -> Vector2:
	match item:
		'-': return Vector2(0, 25)
		'!': return Vector2(0, -5)
		':': return Vector2(0, 7)
		"'": return Vector2(0, -5)
		_: return Vector2.ZERO

class Letter extends AnimatedSprite2D:
	const ALPHABET = 'abcdefghijklmnopqrstuvwxyz'
	const SYMBOLS = "(){}[]\"!@#$%'*+-=_.,:;<>?^&\\/|~"
	const NUMBERS = '1234567890'
	
	var is_bold:bool = true
	var char:String = ''
	var id:int = 0
	var row:int = 0
	
	var _width = 0: 
		get: return get_thing('width')
	var _height = 0: 
		get: return get_thing('height')
	
	func _init(pos:Vector2, char:String, id:int, row:int):
		self.position = pos; self.char = char;
		self.id = id; self.row = row;
		
	func get_thing(the:String):
		if sprite_frames == null or !sprite_frames.has_animation(char): return 47.0 if the == 'width' else 65.0
		if the == 'width': return sprite_frames.get_frame_texture(char, 0).get_width()
		if the == 'height': return sprite_frames.get_frame_texture(char, 0).get_height()
