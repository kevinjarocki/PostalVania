extends Node2D

var time = 0
var complete = false

func _process (delta):
	if !complete:
		time += delta
		$Player2/Control/Timer.text = ("%.2f" %time + " sec")

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			$Player2.position = Vector2(0,0)

func _on_area_2d_body_entered(body: Node2D) -> void:
	complete = true
	pass # Replace with function body.
