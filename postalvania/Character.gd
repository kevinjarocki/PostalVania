extends AnimatedSprite2D 

var first_touch = true

signal character_touched(first_touch)

func _on_area_2d_body_entered(body: Node2D) -> void:
	character_touched.emit(first_touch)
	first_touch = false
	print ("here")
	pass # Replace with function body.
