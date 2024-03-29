class_name Alphabet; extends Control;

var width:float = 0
var height:float = 0
var spaces:int = 0
var rows:int = 0

var x_diff:int = 45
var y_diff:int = 65
@export var bold:bool = false
var text:String = '':
	set(new_txt):
		while get_child_count() > 0:
			get_child(0).queue_free()
			remove_child(get_child(0))
		text = new_txt.replace("\\n", "\n")
		make_text(text)

var is_menu:bool = false
var lock = Vector2(-1, -1)
var target_y:int = 0
var spacing:int = 150
func make_text(text:String):
	var letters_made:Array[Letter] = []
	
	var sheet:SpriteFrames = load('res://assets/images/ui/alphabet/%s.res' % ['bold' if bold else 'normal'])

	var offsets = Vector2.ZERO
	width = 0
	height = 0
	
	var cur_loop:int = 0
	for i in text.split():
		var is_space = (i == ' ')
		if is_space: spaces += 1
		if i == '\n': rows += 1
		
		if spaces != 0: offsets.x += x_diff * spaces
		spaces = 0
		
		if rows != 0:
			offsets.x = 0
			offsets.y += y_diff * rows
		rows = 0
		
		var anim = get_anim(i)
		var letter = Letter.new(offsets, i, cur_loop, rows)
		if anim != '' and is_instance_valid(sheet):
			var e:= sheet.get_frame_texture(anim, 0)
			var let:String = anim if e != null else "?"

			letter.sprite_frames = sheet
			letter.play(let)
			letter.offset = Vector2.ZERO #true_offsets
			offsets.x += 47 #letter._width
			
		letters_made.append(letter)
		cur_loop += 1
		
	for i in letters_made:
		if i.char != '': width += 47 #i._width
		add_child(i)
	height = letters_made.back()._height
	letters_made.clear()

func _process(delta):
	if is_menu:
		var remap_y:float = remap(target_y, 0, 1, 0, 1.1)
		var scroll:Vector2 = Vector2(
			lock.x if lock.x != -1 else lerpf(position.x, (target_y * 35) + 230, (delta / 0.16)),
			lock.y if lock.y != -1 else lerpf(position.y, (remap_y * spacing) +
			 (Game.screen[0] * 0.28), (delta / 0.16))
		)
		position = scroll

func get_anim(item):
	item = item.dedent()
	match item:
		"{": return "(" if !bold else "{"
		"}": return ")" if !bold else "}"
		"[": return "(" if !bold else "["
		"]": return ")" if !bold else "]"
		"&": return "amp"
		"!": return "exclamation"
		"'": return "apostrophe"
		_:
			if item == null or item == "" or item == "\n": return ""
			if !bold:
				if Letter.ALPHABET.find(item.to_lower()) != -1:
					var casing = "case"
					casing = (' upper' if item.to_lower() != item else ' lower') + casing
					return "%s".dedent() % [item.to_lower() + casing]
			return item.to_lower().dedent()

class Letter extends AnimatedSprite2D:
	const ALPHABET = 'abcdefghijklmnopqrstuvwxyz'
	const SYMBOLS = "(){}[]\"!@#$%'*+-=_.,:;<>?^&\\/|~"
	const NUMBERS = '1234567890'
	
	var is_bold:bool = true
	var char:String = ''
	var id:int = 0
	var row:int = 0
	
	var _width = 0: 
		get: return sprite_frames.get_frame_texture(char, 0).get_width()
	var _height = 0: 
		get: return sprite_frames.get_frame_texture(char, 0).get_height()
	
	func _init(pos:Vector2, char:String, id:int, row:int):
		self.position = pos; self.char = char;
		self.id = id; self.row = row;
