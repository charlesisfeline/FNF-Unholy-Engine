extends Node2D

var update_id:bool = true

var can_rpc:bool
var _info = {id = 1225971084998737952, l_img = 'deedee_phantonm', l_txt = 'out here unholy-ing baby'}

var last_presence:Array[String] = [] # hold the actual presence text, so it can swap
func init_discord() -> void:
	print('Initializing Discord...')
	# yes the daniel pref is very necessary
	if Prefs.daniel:
		_info = {id = 1227081103932657664, l_img = 'daniel', l_txt = 'I LOVE DANIEL'}
	
	if update_id:
		update_id = false
		DiscordRPC.app_id = _info.id
	DiscordRPC.large_image = _info.l_img
	DiscordRPC.large_image_text = _info.l_txt
	DiscordRPC.start_timestamp = int(Time.get_unix_time_from_system())

	if !last_presence.is_empty():
		change_presence(last_presence[0], last_presence[1])
	else:
		change_presence()
	DiscordRPC.run_callbacks()
	print('Discord Initiated')

func clear() -> void:
	DiscordRPC.clear(true) # it takes a bit for it to actually stop showing
	
func _process(_delta):
	can_rpc = Prefs.allow_rpc and DiscordRPC.get_is_discord_working()
	if can_rpc: 
		DiscordRPC.run_callbacks()

func change_presence(main:String = 'Nutthin', sub:String = 'Check it') -> void:
	last_presence = [main, sub]
	DiscordRPC.details = 'I LOVE DANIEL' if Prefs.daniel else main
	DiscordRPC.state = 'I LOVE DANIEL' if Prefs.daniel else sub
	if can_rpc: DiscordRPC.refresh()
