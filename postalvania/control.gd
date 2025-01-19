extends Control

var camera_size
var camera_rect
var camera_zoom
var camera
var default_position

var temp = 0

func _ready() -> void:
	camera = $"../Player/Camera2D"
	default_position = position
	camera_zoom = camera.zoom
	
func _process(delta):

	camera_size = (get_viewport().get_visible_rect().size * (1/camera.zoom.x) * .98)
	camera_rect = Rect2(camera.get_screen_center_position() - (camera_size / 2), camera_size)
	size = camera_size
	position = camera.get_screen_center_position() - (size/2)
