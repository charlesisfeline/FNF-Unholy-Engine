extends Node2D

enum RET_TYPES {}
var cached_items:Dictionary = {}
var active_lua:Array = []
var active:bool = true

func add_script(script:String) -> void:
	var lua = TEst.new()
	#LuaHandler.add_script('')
	#var lua = LuaAPI.new()
	#lua.bind_libraries(["base", "table", "string", "math"])
	#lua.push_variant('boyfriend', boyfriend)
	#lua.push_variant('Game', self)
	#lua.push_variant('print', print)
	
	#lua.do_string("
	#	--boyfriend.position = Vector2(100, 100)
		
	#	--Game.ui.zoom = 100
	#	--os.exit()
	#")
	#ui.icon_p1.change_icon(boyfriend.icon, true)
	
	#if lua is not LuaError:
	#	var le = lua.pull_variant('hi')
	#	if le is not LuaError:
	#		print(le.position.x)
	#lua.do_file('res://assets/songs/test/test.lua')
	#active_luas.append(lua)
	#if lua is LuaError:
	#	printerr(lua.message)
	#	active_luas.remove_at(active_luas.find(lua))
	#print(lua.call_function('hi', []))
	
	lua.bind_libraries(["base", "table", "string", "math"])
	
	## Objects ##
	lua.push_variant("Conductor", Conductor)
	lua.push_variant('Character', Character)
	lua.push_variant('Game', Game.scene) # current scene
	if Game.scene.name == 'Play_Scene':
		
		lua.push_variant('Chart', Chart)
		lua.push_variant('UI', Game.scene.ui)
		lua.push_variant('boyfriend', Game.scene.boyfriend)
		lua.push_variant('gf', Game.scene.gf)
		lua.push_variant('dad', Game.scene.dad)
		
		lua.push_variant("add_char", add_character)

	
	lua.push_variant("Sprite", LuaSprite)
	lua.push_variant("AnimatedSprite", LuaAnimatedSprite)
	
	## Lua Functions ##
	lua.push_variant('parse_json', parse_json)
	lua.push_variant("play_sound", Audio.play_sound)
	lua.push_variant("play_music", Audio.play_music)
	lua.push_variant("cache", cache_file)
	lua.push_variant("get_cache", get_cached_file)

	lua.do_file('res://assets/data/scripts/test.lua')
	if lua is LuaError:
		printerr(lua.message)
		return
	active_lua.append(lua)
	
func remove_all():
	while active_lua.size() > 0:
		active_lua[0] = null
		#active_lua[0].unreference()
		active_lua.remove_at(0)
	active_lua.clear()

func call_func(_func:String, args:Array = []) -> void:
	if _func.length() == 0: return
	for i in active_lua:
		if !i.function_exists(_func): continue
		i.call_function(_func, args)
	#print('Called: ('+ _func +') on luas')
	
## FUNCTIONS FO LUA CRIPTS 😎😎
func pain(x):
	return (x^x^x^x^x^x^x^x^x^x^x^x^x^x)^-x
	
func add_obj(obj:Variant = null, to_group:Variant = null):
	if obj != null:
		if to_group != null:  pass
	add_child(obj)

func cache_file(tag:String, file_path:String):
	if cached_items.has(tag):
		print(tag +' already cached, overwriting')
	var check = file_path.split('/')
	if check[check.size() - 1].split('.').size() == 0:
		printerr('file type not specified, assuming ".png"')
		file_path += '.png'
		
	cached_items[tag] = load('res://assets/'+ file_path)

func get_cached_file(tag:String):
	return cached_items[tag] if cached_items.has(tag) else load('res://assets/images/logoBumpin.png')
	
func add_variant(variant:String):
	if !variant.is_empty():
		pass
			#for lua in active_lua:
			#	lua.push_variant(variant, ClassDB.get_class())
func add_character(char:Character):
	Game.scene.characters.append(char)
	if Game.scene.stage.has_node('CharGroup'):
		Game.scene.stage.get_node('CharGroup').add_child(char)
	else:
		Game.scene.add_child(char)

func parse_json(path:String):
	if !path.ends_with('.json'): path += '.json'
	if !ResourceLoader.exists('res://assets/'+ path):
		printerr('Nope')
		return
	var le_json = FileAccess.open('res://assets/'+ path, FileAccess.READ).get_as_text()
	return JSON.parse_string(le_json)

func makeLuaSprite(_t, _sp, _x, _y):
	get_tree().exit()

## LUA OBJECTS
class LuaSprite extends Sprite2D:
	func load_texture(spr:String):
		texture = load('res://assets/images/'+ spr +'.png')
		
class LuaAnimatedSprite extends AnimatedSprite2D:
	var offsets:Dictionary = {}
	func load_anims(path:String):
		offsets.clear()
		sprite_frames = load('res://assets/images/'+ path +'.res')
	
	func add_offset(anim:String, offs:Array = [0, 0]):
		offsets[anim] = Vector2(offs[0], offs[1])
	
	func play_anim(anim:String, forced:bool = true, reverse:bool = false):
		if sprite_frames.has_animation(anim):
			play(anim)
			if forced: frame = sprite_frames.get_frame_count(anim) - 1 if reverse else 0
			var da_off:Vector2 = Vector2.ZERO
			if offsets.has(anim):
				da_off = offsets[anim]
				
			offset = da_off
			
class TEst extends LuaAPI:
	func _notification(what:int) -> void:
		match what:
			NOTIFICATION_PREDELETE:
				print("good-bye")
