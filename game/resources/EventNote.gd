class_name EventNote; extends Resource;

var strum_time:float = 0.0
var event:String = ''
var values:Array[Variant] = []

func _init(new_event):
	strum_time = new_event[0]
	event = new_event[1][0][0]
	values.append(new_event[1][0][1])
	values.append(new_event[1][0][2])
