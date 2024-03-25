extends Node2D

var preferences:Dictionary = {
	'downscroll': false, 'middlescroll': false, 'splitscroll': false, # scroll types
	'auto_play': false,
	'hitsounds': false,
	'offset': 0,
	'sick_window': 45,
	'good_window': 90,
	'bad_window': 135
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func get_pref(pref):
	return preferences[pref]

func set_pref(pref, to):
	if preferences.has(pref):
		preferences[pref] = to
	else:
		printerr('PREFERENCES: ' + pref + ' NOT FOUND')
		return null
