class_name NoteData; extends Resource;

var strum_time:float
var must_press:bool
var dir:int

var speed:float
var type:String

var length:float

func _init(data):
	if data != null and data is Array:
		strum_time = floor(data[0])
		dir = int(data[1]) % 4
		if !(data[3] is float): data[3] = 0
		length = data[3]
		must_press = data[4]
		type = data[5]
