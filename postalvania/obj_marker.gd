extends Node2D

var sprite
var spriteLoc = Vector2(99,99)
var camera

func _ready() -> void:
	camera = $"../Player/Camera2D"
	sprite = $Sprite2D
	spriteLoc = $"../Character".global_position

func _process(delta: float) -> void:
	var camera_size = get_viewport_rect().size * camera.zoom
	var camera_rect = Rect2(camera.get_screen_center_position() - camera_size / 2, camera_size)
	set_marker_position(camera_rect)
	
func set_marker_position(bounds : Rect2):
	print(bounds)
	sprite.position.x = clamp(spriteLoc.x, bounds.position.x, bounds.end.x)
	sprite.position.y = clamp(spriteLoc.y, bounds.position.y, bounds.end.y)
	
