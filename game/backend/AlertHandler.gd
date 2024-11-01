extends Node

const ALERT = preload('res://game/objects/alert_window.tscn')

var all_alerts:Array = []
var alert_count:int = 0

func make_alert(info:Array = [], type:String = 'alert') -> void:
	var new_alert = ALERT.instantiate()
	add_child(new_alert)
	new_alert.text = 'Hi!'
	new_alert.position = Vector2(0, Game.screen[1] - (150 * alert_count))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
