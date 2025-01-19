extends Node2D

var timerPause = false
var stage = 0
var cur_stage = 0
var totalTime = 0
var stageStartTime = [0,0,0,0,0,0,0,0]
var stageStep = [0,0,0,0,0,0,0,0]

var velocity = 0

var giverObjExist = false

var nodePanelTLArray = []
var nodeTLArray = []
var nodeTLTimerArray = []
var giverNPCArray = []
var receiverNPCArray = []
var markerArray = [0,0,0,0,0,0,0,0]

#New arrays
var giverArrayFix = [Vector2(-12164, 644), Vector2(-8284, -110), Vector2(-702, 42), Vector2(-1919, -947),
Vector2(2028, 980), Vector2(3077, -137), Vector2(5841, -643), Vector2(-653, -5031)]

var receiverArrayFix = [Vector2(-9997, 621), Vector2(-2849, 759), Vector2(-174, 4165), Vector2(-71, -5068),
Vector2(-3490, -1399), Vector2(12365, 307), Vector2(-11818, 319), Vector2(116, 4156)]

#Text to display in dbox from chickens
var giverFirstTouchDBox = ["Welcome to the wonderful world of ParcelVania. Here you assist the villagers by delivering parcels they give you. You can also touch cows to unlock great abilities",
	"Here is the second text box for the second chicken delivery",
	"Here is the third text box for the third chicken delivery",
	"Here is the fourth text box for the fourth chicken delivery",
	"Here is the fifth text box for the fifth chicken delivery",
	"Here is the sixth text box for the sixth chicken delivery",
	"Here is the seventh text box for the seventh chicken delivery",
	"Here is the eigth text box for the 8 chicken delivery"]
var giverNextTouchDBox = ["I already gave you my package, please deliver it! They're in the moss",
	"I already gave you my package, please deliver it! They're in the tree",
	"I already gave you my package, please deliver it! They're in the desert",
	"I already gave you my package, please deliver it! They're in the lake",
	"I already gave you my package, please deliver it! They're in the messhall",
	"I already gave you my package, please deliver it! They're in the grasslands",
	"I already gave you my package, please deliver it! They're in the village",
	"I already gave you my package, please deliver it! They're in the car"]
var receiverPreQuestDBox = ["I'm looking for a package 1",
	"I'm looking for a package 2",
	"I'm looking for a package 3",
	"I'm looking for a package 4",
	"I'm looking for a package 5",
	"I'm looking for a package 6",
	"I'm looking for a package 7",
	"I'm looking for a package 8"]
var receiverCompletingQuestDBox = ["Thanks for delivering this! I appreciate it",
	"Thanks for delivering this! I appreciate it",
	"Thanks for delivering this! I appreciate it",
	"Thanks for delivering this! I appreciate it",
	"Thanks for delivering this! I appreciate it",
	"Thanks for delivering this! I appreciate it",
	"Thanks for delivering this! I appreciate it",
	"Thanks for delivering this! I appreciate it"]

@onready var ObjMarker = preload("res://obj_marker.tscn")
@onready var CharPair = preload("res://char_pair.tscn")

func _ready():

	nodeTLArray = get_tree().get_nodes_in_group("TL")
	nodeTLTimerArray = get_tree().get_nodes_in_group("TLTimer")
	nodePanelTLArray = $Control/VBoxContainer.get_children()
	
	for x in 8:
		var charPairInstance = CharPair.instantiate()
		add_child(charPairInstance)
		var charPairChildren = charPairInstance.get_children()
		charPairChildren[0].position = giverArrayFix[x]
		print(charPairChildren)
		charPairChildren[1].position = receiverArrayFix[x]
		
		charPairChildren[0].char_id = x
		charPairChildren[1].char_id = x
		
	
	giverNPCArray = get_tree().get_nodes_in_group("Giver")
	receiverNPCArray = get_tree().get_nodes_in_group("Receiver")
	
	#var counter = 0
	#for x in giverNPCArray:
		#x.char_id = counter
		#counter += 1
#
	#counter = 0
	#for x in receiverNPCArray:
		#x.char_id = counter
		#counter += 1
		
func _process (delta):
	if !timerPause:
		totalTime += delta
		
	$Control/VBoxContainer2/Timer.text = ("%.1f" %totalTime + " sec")
	
	for x in len(stageStep):
		if stageStep[x] == 1:
			var temp = totalTime - stageStartTime[x]
			nodeTLTimerArray[x].text = ("%.1f" %temp + " sec")
	
	velocity = ($Player.velocity.length() / 100) - 0.1
	$Control/VBoxContainer2/Velocity.text = ("%.1f" %velocity + " m/sec")
	
func _unhandled_input(event):
	
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			$Player.position = $"Respawn Point".position
			$Player.isGrounded = false
			$Player.isJumping = false
			$Player.isInAir = true
			$Player.isSwinging = false
			$Player.isGliding = false

		if event.pressed and event.keycode == KEY_SPACE and $Control/NinePatchRect.visible and $Timer.is_stopped() && !$Player.cutsceneActive:
			$Control/NinePatchRect.visible = false
			await get_tree().create_timer(.01).timeout
			$Player.frozen = false
			timerPause = false
	
func _dBox (text, text2 = "", sprite = false):
	$Timer.start()
	$Control/NinePatchRect/DialogueText.text = text
	timerPause = true
	$Control/NinePatchRect.visible = true
	$Player.frozen = true
	$Control/NinePatchRect/Received.text = text2
	
	
	if typeof(sprite) == TYPE_INT:
		$Control/NinePatchRect/DialogueSprite.visible = true
		$Control/NinePatchRect/DialogueSprite.frame = sprite
	else:
		$Control/NinePatchRect/DialogueSprite.visible = false
	
func _on_quest_giver_character_touched(first_touch, char_id, charPosition):
	print("Im being called")
	if first_touch:
		_dBox(giverFirstTouchDBox[char_id], "Received: ", char_id)
		var instance = ObjMarker.instantiate()
		add_child(instance)
		markerArray[char_id] = instance
		instance.spriteLoc = charPosition
		instance.itemSpriteFrame = char_id
		stageStep[char_id] = 1
		stageStartTime[char_id] = totalTime
		$Control/VBoxContainer.move_child(nodePanelTLArray[char_id], 0)
		nodePanelTLArray[char_id].visible = true
		nodeTLArray[char_id].set_frame(char_id)
		
		if (get_tree().get_nodes_in_group("GiverObj")):
			if char_id == giverObjExist:
				giverObjExist = false
				var temp = get_tree().get_nodes_in_group("GiverObj")
				temp[0].queue_free()
	
	else:
		_dBox(giverNextTouchDBox[char_id])
		
func _on_quest_delivery_character_touched(first_touch, char_id, charPosition):
	
	if stageStep[char_id] == 2:
		_dBox("You've already delived to me! Thanks for the assistance.")
	
	elif stageStep[char_id] == 1:
		_dBox(receiverCompletingQuestDBox[char_id])
		stageStep[char_id] = 2
		markerArray[char_id].queue_free()
		
		if stageStep.count(2) == 8:
			_complete_game()
		
	elif stageStep[char_id] == 0:
		_dBox(receiverPreQuestDBox[char_id])
		
func _job_board(char_id):
	
	var instance = ObjMarker.instantiate()
	add_child(instance)
	instance.add_to_group("GiverObj")
	instance.spriteLoc = giverNPCArray[char_id].position + Vector2(0, -50)
	instance.itemSpriteFrame = char_id
	instance.modulate = Color.RED
	instance.modulate.a = .8
	giverObjExist = char_id
	
func _complete_game():
	$HiScore.position = $HiScore.position + $Player.position
	$HiScore.start()
