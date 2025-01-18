extends Control


func _on_play_pressed():
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://main.tscn")

func _on_options_pressed():
	await get_tree().create_timer(0.5).timeout

func _on_quit_pressed():
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()


func _on_how_to_play_pressed():
	await get_tree().create_timer(0.5).timeout
