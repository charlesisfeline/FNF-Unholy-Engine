extends Node

const ALERT = preload('res://game/objects/alert_window.tscn')

var all_alerts:Array = []
var alert_count:int = 0

func make_alert(info:Array = [], type:String = 'alert') -> void:
	var new_alert = ALERT.instantiate()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
