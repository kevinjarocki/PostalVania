extends Control


func _on_back_to_menu_pressed() -> void:
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://main_menu.tscn")
