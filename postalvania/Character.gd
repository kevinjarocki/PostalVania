extends AnimatedSprite2D 

var first_touch = true

signal character_touched(first_touch)

func _on_area_2d_body_entered(body: Node2D) -> void:
	character_touched.emit(first_touch)
	if first_touch:
		character_touch ()
	first_touch = false
	pass # Replace with function body.

func character_touch ():
	$"..".stage += 1
	$"..".timerPause = true
	$"../Player/Control/NinePatchRect".visible = true
	$"../Player/Control/NinePatchRect/DialogueSprite".frame = $"..".stage
	$"../Player".process_mode = Node.PROCESS_MODE_DISABLED
	
	if $"..".stage > 1:
		$"..".completeTime()
