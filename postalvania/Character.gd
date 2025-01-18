extends AnimatedSprite2D 

var first_touch = true
var interactable = true
var char_id = 0

signal character_touched(first_touch, char_id, charPosition)

func _on_area_2d_body_entered(body: Node2D) -> void:
	
	var charPosition = $"../QuestDelivery".position + Vector2(0, -30)
	character_touched.emit(first_touch, char_id, charPosition)
	first_touch = false
