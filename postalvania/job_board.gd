extends Node2D

var mainNode

@onready var ObjMarker = preload("res://obj_marker.tscn")

func _ready() -> void:
	mainNode = $".."

func _on_area_2d_body_entered(body: Node2D) -> void:

	if !mainNode.giverObjExist:

		var temp = []
		for x in mainNode.stageStep.size():
			if mainNode.stageStep[x] == 0:
				temp.append(x)
		if temp.size() != 0:
			mainNode._job_board(temp.pick_random())
