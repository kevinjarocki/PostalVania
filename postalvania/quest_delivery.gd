extends AnimatedSprite2D 

var first_touch = true
var interactable = true
var char_id = 0
var MainNode

signal character_touched(first_touch, char_id, charPosition)


func _ready() -> void:
	MainNode = get_parent().get_parent()
	#if(is_in_group("Receiver")):
		#connect("character_touched", $"../.."._on_quest_delivery_character_touched.bind())
	#else:
		#connect("character_touched", Callable($"../..", "_on_quest_giver_character_touched(first_touch, char_id, charPosition)"))
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	
	var charPosition = $"../QuestDelivery".position + Vector2(0, -50)
	

	MainNode._on_quest_delivery_character_touched(first_touch, char_id, charPosition)
	first_touch = false
