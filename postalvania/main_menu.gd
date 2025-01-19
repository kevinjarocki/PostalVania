extends Control

var cursor = load("res://Assets/menu/cursor/cursor04_gr16x16.png")

func _process(delta: float):
	$DirectionalLight2D.energy = 0.6 - (($CanvasLayer/MarginContainer/VBoxContainer/Panel/HSlider.value)/100 - .5)

func _on_play_pressed():
	Singleton.brightnessSelected = $CanvasLayer/MarginContainer/VBoxContainer/Panel/HSlider.value
	if $CanvasLayer/MarginContainer/VBoxContainer/CheckBox.button_pressed:
		Singleton.lowGravMode = true
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://main.tscn")

func _on_options_pressed():
	await get_tree().create_timer(0.5).timeout

func _on_quit_pressed():
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()


func _on_how_to_play_pressed():
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://how_to_play.tscn")


func _on_ready() -> void:
	Input.set_custom_mouse_cursor(cursor)
	pass # Replace with function body.
