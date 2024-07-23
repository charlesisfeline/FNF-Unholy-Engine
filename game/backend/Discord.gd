extends Node2D

# yes the daniel pref is very necessary 
func _ready():
	pass
	#DiscordRPC.run_callbacks()
	#DiscordRPC.refresh()
	#print(DiscordRPC.get_is_discord_working())
	#if Prefs.allow_rpc:
	#	init_discord()
	#DiscordRPC.get_current_user().username

var last_presence:Array[String] = ['', ''] # hold the actual presence text, so you can swap
func init_discord() -> void:
	print('Initializing Discord...')
	var _id:int = 1227081103932657664 if Prefs.daniel else 1225971084998737952
	var _l_img:String = 'daniel' if Prefs.daniel else 'fembo'
	var _l_txt:String = 'I LOVE DANIEL' if Prefs.daniel else 'out here unholy-ing baby'
	DiscordRPC.app_id = _id
	DiscordRPC.large_image = _l_img
	DiscordRPC.large_image_text = _l_txt
	DiscordRPC.start_timestamp = int(Time.get_unix_time_from_system())
	if last_presence[0].length() != 0:
		change_presence(last_presence[0], last_presence[1])
	else:
		change_presence()
	DiscordRPC.run_callbacks()
	print_debug('Discord Initiated')

func clear() -> void:
	DiscordRPC.clear(true) # it takes a bit for it to actually stop showing
	
func _process(_delta):
	if Prefs.allow_rpc: 
		DiscordRPC.run_callbacks()

func change_presence(main:String = 'Nutthin', sub:String = 'Check it') -> void:
	last_presence = [main, sub]
	DiscordRPC.details = 'I LOVE DANIEL' if Prefs.daniel else main
	DiscordRPC.state = 'I LOVE DANIEL' if Prefs.daniel else sub
	if DiscordRPC.get_is_discord_working() and Prefs.allow_rpc:
		DiscordRPC.refresh()
