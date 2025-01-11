extends Node2D

var timerPause = false
var stage = 0
var cur_stage = 0
var time = [0]
var completedTime = [0]

var nodeTLArray = []
var nodeTLTimerArray = []

func _ready():
	nodeTLArray = get_tree().get_nodes_in_group("TL")
	nodeTLTimerArray = get_tree().get_nodes_in_group("TLTimer")
	
func _process (delta):
	if !timerPause:
		time[0] += delta
		
	$Player/Control/Timer.text = ("%.2f" %time[0] + " sec")
	
	if cur_stage != stage and stage < 7:
		cur_stage = stage
		time.append(time[0])
		nodeTLArray[stage-1].visible = true
	
	if stage > 0 and stage < 7:
		nodeTLTimerArray[stage-1].text = ("%.2f" %(time[0]-time[stage]) + " sec")

func _unhandled_input(event):
	
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			$Player.position = Vector2(0,0)
			$Player.isGrounded = false
			$Player.isJumping = false
			$Player.isInAir = true
			$Player.isSwinging = false
			$Player.isGliding = false

		if event.pressed and event.keycode == KEY_SPACE and $Player/Control/NinePatchRect.visible and stage != 7:
			$Player/Control/NinePatchRect.visible = false
			await get_tree().create_timer(.01).timeout
			$Player.process_mode = Node.PROCESS_MODE_PAUSABLE
			timerPause = false
			$Player/Control/Container/TL1.visible = true

func completeTime():
	completedTime.append(time[0]-time[stage-1])
	nodeTLTimerArray[stage-2].text = "%.2f" %completedTime[stage-1] + " sec"
	
func _on_character_character_touched(first_touch: Variant) -> void:
	if first_touch:
		$Player/Control/NinePatchRect/DialogueText.text = "Thank you for getting to me! Please deliver this package to the right! My friend the cat is waiting."
	pass # Replace with function body.

func _on_character_2_character_touched(first_touch: Variant) -> void:
	if first_touch:
		$Player/Control/NinePatchRect/DialogueText.text = "Thanks for the delivery! I love that chicken! Please deliver this to the other chicken to my immediate right."
	pass # Replace with function body.

func _on_character_3_character_touched(first_touch: Variant) -> void:
	pass # Replace with function body.

func _on_character_4_character_touched(first_touch: Variant) -> void:
	pass # Replace with function body.

func _on_character_5_character_touched(first_touch: Variant) -> void:
	pass # Replace with function body.

func _on_character_6_character_touched(first_touch: Variant) -> void:
	pass # Replace with function body.

func _on_character_7_character_touched(first_touch: Variant) -> void:
	$Player/Control/NinePatchRect/DialogueText.text = "Thanks for the delivery! I love that chicken! You win!!. Your final total time is: " + ("%.2f" %time[0] + " sec")
	$Player/Control/NinePatchRect/DialogueSprite.visible = false
	$Player/Control/NinePatchRect/Received.visible = false
	pass # Replace with function body.
