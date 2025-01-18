extends Control

var camera_size
var camera_rect
var camera

func _ready() -> void:
	camera = $"../Camera2D"
	
func _process(delta):
	camera_size = get_viewport().get_visible_rect().size * (1/.6) * .98
	camera_rect = Rect2(camera.get_screen_center_position() - (camera_size / 2), camera_size)
	#
	size = camera_size
	position = -(camera_size / 2)
