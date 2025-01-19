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
var giverFirstTouchDBox = ["Welcome to the wonderful world of ParcelVania! Can you please deliver this cookie to my fairy friend? They should be just to the right of me on the other side of the wall! A glide ability might help you out.",
	"Hi there, my fairy friend loves cheese. He is wearing a red outfit like mine. Can you please deliver this cheese to him, he is at the base of the tree in a cave?",
	"Hi there! Can you please deliver this aged booze to the pink fairy in the deep roots of the tree?",
	"Mmmmmm I love pretzels mmmmm. I bought an extra pretzel for my green fairy friend. Can you go to the top of the tree and deliver him the pretzel?",
	"Help! My fairy is very sick, he needs this special red medicince or he will die. He is wearing a mustard shirt. Please hurry and bring this to him, he is on a floating island in the north-west of our world!",
	"Hehehe I just bought this scary mask for my friend. It's perfect for halloween. He is wearing a vintage yellow shirt and wings. Please go to the crystal caverns in the east.",
	"I found this apple with a nasty worm living inside it. It would be funny if a fairy ate it. Give it to the cyan colored fairy at the western gardens.",
	"Hey! I love beer, you love beer, we all love beer! My partner especially loves beer. He loves wearing purple to match his wings. Go to the tree roots and get him this drink."]
	
var giverNextTouchDBox = ["I already gave you my package, please deliver it. They're to the right of me.",
	"I already gave you my package, please deliver it. They're at ground level to the west of the central tree.",
	"I already gave you my package, please deliver it. They're at the southern most point of our world. You can get there by going down the central tree.",
	"I already gave you my package, please deliver it. They're at the northern most point of our world. You can get there by going up the central tree.",
	"I already gave you my package, please deliver it. They're on the north-western floating islands.",
	"I already gave you my package, please deliver it. They're in the eastern most part of our world. In the crystal caverns.",
	"I already gave you my package, please deliver it. They're in the western most part of our world. In the great gardens.",
	"I already gave you my package, please deliver it. They're at the southern most point of our world. You can get there by going down the central tree."]
	
var receiverPreQuestDBox = ["I think the owl on the other side of my wall wants to give me something.",
	"I think the owl at the entrance of the western gardens wants to give me something.",
	"I think the owl in the central town wants to give me something.",
	"I think the owl on the floating island just north-west of the central town wants to give me something.",
	"I think the owl to the south-east of the central town wants to give me something.",
	"I think the owl in the vines to the east of the central town wants to give me something.",
	"I think there is an owl between the central town and the crystal caves has something to give me.",
	"I think the owl at the top of the tree wants to give me something."]
	
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
		charPairChildren[1].position = receiverArrayFix[x]
		
		charPairChildren[0].char_id = x
		charPairChildren[1].char_id = x
		charPairChildren[0].frame = charPairChildren[0].char_id
		charPairChildren[1].frame = charPairChildren[1].char_id
	giverNPCArray = get_tree().get_nodes_in_group("Giver")
	receiverNPCArray = get_tree().get_nodes_in_group("Receiver")
	
	$Lighting/DirectionalLight2D.energy -= (Singleton.brightnessSelected)/100 - .5
	
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
	
	elif (stageStep[char_id] == 1):
		_dBox(giverNextTouchDBox[char_id])
	
	elif (stageStep[char_id] == 2):
		_dBox("Thanks for delivering my package! I appreciate it!")
		
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
