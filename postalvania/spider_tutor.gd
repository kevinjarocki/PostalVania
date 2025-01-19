extends Node2D

var direction = 1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotate(direction*delta)
	if rotation > PI/2:
		direction = -1
		
	elif rotation < -PI/2:
		direction = 1
