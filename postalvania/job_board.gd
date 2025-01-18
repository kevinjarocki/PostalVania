extends Node2D

var mainNode

@onready var ObjMarker = preload("res://obj_marker.tscn")

func _ready() -> void:
	mainNode = $".."

func _on_area_2d_body_entered(body: Node2D) -> void:
	
	for x in mainNode.stageStep.size():
		if mainNode.stageStep[x] == 0:
			var instance = ObjMarker.instantiate()
			mainNode.add_child(instance)
			instance.add_to_group("Temp")
			instance.spriteLoc = mainNode.giverNPCArray[x].position + Vector2(0, -50)
			instance.itemSpriteFrame = x
		
func _on_area_2d_body_exited(body: Node2D) -> void:
	for x in get_tree().get_nodes_in_group("Temp"):
		x.queue_free()
	pass # Replace with function body.
