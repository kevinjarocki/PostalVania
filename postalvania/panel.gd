extends Panel

var _name = "Temp name"
var _time = "Temp time"

func _ready() -> void:
	$Label.text = _name
	$Label2.text = _time
