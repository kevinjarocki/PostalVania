extends Node2D

var timerPause = false
var stage = 0
var cur_stage = 0
var time = [0]
var completedTime = [0]

var nodeTLArray = []
var nodeTLTimerArray = []
var nodeNPCArray = []

#Text to display in dbox from chickens
var firstTouchDBox = ["Welcome to the wonderful world of ParcelVania. Here you assist chickens by delivering parcels they give you. You can also touch cows to unlock great abilities",
"Here is the second text box for the second chicken"]

@onready var ObjMarker = preload("res://obj_marker.tscn")

func _ready():
	nodeTLArray = get_tree().get_nodes_in_group("TL")
	nodeTLTimerArray = get_tree().get_nodes_in_group("TLTimer")
	nodeNPCArray = get_tree().get_nodes_in_group("NPC")	
	
	$CharPair/QuestGiver.char_id = 0
	$CharPair/QuestDelivery.char_id = 1
	
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
		$ObjMarker.spriteLoc = nodeNPCArray[stage].global_position + Vector2(0,-25)

func _unhandled_input(event):
	
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			$Player.position = $"Respawn Point".position
			$Player.isGrounded = false
			$Player.isJumping = false
			$Player.isInAir = true
			$Player.isSwinging = false
			$Player.isGliding = false

		if event.pressed and event.keycode == KEY_SPACE and $Player/Control/NinePatchRect.visible and stage != 7:
			$Player/Control/NinePatchRect.visible = false
			await get_tree().create_timer(.01).timeout
			$Player.frozen = false
			timerPause = false
			$Player/Control/Container/TL1.visible = true

func completeTime():
	completedTime.append(time[0]-time[stage-1])
	nodeTLTimerArray[stage-2].text = "%.2f" %completedTime[stage-1] + " sec"
	
func _dBox (text, text2 = "", sprite = false):
	$Player/Control/NinePatchRect/DialogueText.text = text
	timerPause = true
	$Player/Control/NinePatchRect.visible = true
	$Player.frozen = true
	$Player/Control/NinePatchRect/Received.text = text2
	
	if sprite:
		$Player/Control/NinePatchRect/DialogueSprite.visible = true
		$Player/Control/NinePatchRect/DialogueSprite.frame = sprite
	else:
		$Player/Control/NinePatchRect/DialogueSprite.visible = false
	
func _on_quest_giver_character_touched(first_touch, char_id):
	if first_touch:
		_dBox(firstTouchDBox[char_id])
		
		
		
	
func _on_quest_delivery_character_touched(first_touch, char_id):
	if first_touch:
		_dBox(firstTouchDBox[char_id])
