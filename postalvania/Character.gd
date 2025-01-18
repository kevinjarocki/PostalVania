extends AnimatedSprite2D 

var first_touch = true
var interactable = true
var char_id = 0

signal character_touched(first_touch, char_id)

func _on_area_2d_body_entered(body: Node2D) -> void:
	
	#if first_touch:
		#$"../.."._dBox("Welcome to the wonderful world of ParcelVania. Here you assist chickens by delivering parcels they give you. You can also touch cows to unlock great abilities")
	#
	#else:
		#$"../.."._dBox("Please deliver my package to the chicken")
	
	character_touched.emit(first_touch, char_id)
	first_touch = false
