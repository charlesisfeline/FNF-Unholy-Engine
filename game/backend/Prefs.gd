extends Node2D

var preferences:Dictionary = {
	'auto_play': false,
	'downscroll': false,
	'offset': 0,
	'hitsounds': false,
	'sick_window': 45,
	'good_window': 90,
	'bad_window': 135
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_pref(pref):
	return preferences[pref]

func set_pref(pref, to):
	if preferences.has(pref):
		preferences[pref] = to
	else:
		printerr('PREFERENCES: ' + pref + ' NOT FOUND')
		return null
