extends Node2D

func _ready():
	DiscordRPC.app_id = 1225971084998737952 # 1227081103932657664 #daniel <3
	DiscordRPC.details = 'Workin on Unholy Engine woop'
	DiscordRPC.state = 'Yuhhh I love daniel'
	DiscordRPC.large_image = 'fembo' #'daniel'
	DiscordRPC.large_image_text = 'out here unholy-ing baby' #'I LOVE DANIEL'
	DiscordRPC.start_timestamp = int(Time.get_unix_time_from_system())
	DiscordRPC.refresh()

func _process(_delta):
	DiscordRPC.run_callbacks()

func change_presence(main:String = 'uhm', sub:String = 'Yuhhh I love daniel'):
	DiscordRPC.details = main #'I LOVE DANIEL'
	DiscordRPC.state = sub #'I LOVE DANIEL'
	DiscordRPC.refresh()
