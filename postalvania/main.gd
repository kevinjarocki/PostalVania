extends Node2D

var time = 0
var time1 = 0
var complete = false

func _process (delta):
	if !complete:
		time += delta
		time1 += delta
		$Player/Control/Timer.text = ("%.2f" %time + " sec")
		$Player/Control/TL1/TL1Timer.text = ("%.2f" %time1 + " sec")

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			$Player.position = Vector2(0,0)

		if event.pressed and event.keycode == KEY_P:
			$Player.position = Vector2(0,0)
			time = 0
			complete = false

		if event.pressed and event.keycode == KEY_SPACE and $Player/Control/NinePatchRect.visible:
			$Player/Control/NinePatchRect.visible = false
			await get_tree().create_timer(.01).timeout
			$Player.process_mode = Node.PROCESS_MODE_PAUSABLE
			time1 = 0
			$Player/Control/TL1.visible = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	complete = true
	pass # Replace with function body.

func _on_character_character_touched(first_touch: Variant) -> void:
	if first_touch:
		$Player/Control/NinePatchRect/DialogueText.text = "Thank you for getting to me! Please deliver this package to the right! My friend the cat is waiting."
		$Player/Control/NinePatchRect.visible = true
		$Player.process_mode = Node.PROCESS_MODE_DISABLED
	pass # Replace with function body.
