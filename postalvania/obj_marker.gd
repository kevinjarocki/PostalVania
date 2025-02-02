extends Node2D

var sprite
var spriteLoc = Vector2(99,99)
var camera
var itemSprite
var itemSpriteFrame = null
var isBound = false

var camera_size
var camera_rect

func _ready() -> void:
	camera = $"../Player/Camera2D"
	sprite = $Sprite2D
	itemSprite = $Sprite2D/AnimatedSprite2D
	await get_tree().create_timer(.01).timeout
	if itemSpriteFrame != null:
		itemSprite.visible = true
		itemSprite.set_frame(itemSpriteFrame)
		
func _process(delta):
	camera_size = get_viewport().get_visible_rect().size * (1/camera.zoom.x) * .80
	camera_rect = Rect2(camera.get_screen_center_position() - (camera_size / 2), camera_size)
	
	set_marker_position(camera_rect)
	set_market_rotation()
	
func set_marker_position(bounds):
	sprite.position.x = clamp(spriteLoc.x, bounds.position.x, bounds.end.x)
	sprite.position.y = clamp(spriteLoc.y, bounds.position.y, bounds.end.y)
	
	if sprite.position.x == bounds.position.x or sprite.position.x == bounds.end.x or sprite.position.y == bounds.position.y or sprite.position.y == bounds.end.y:
		isBound = true
	
	else:
		isBound = false
	
func set_market_rotation():
	if isBound:
		var angle = (spriteLoc - sprite.global_position).angle()
		sprite.rotation = angle
	else:
		var angle = (spriteLoc - sprite.global_position).angle()
		sprite.rotation = angle + 33
	
	$Sprite2D/AnimatedSprite2D.rotation = -sprite.rotation
