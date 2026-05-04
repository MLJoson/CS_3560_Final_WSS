extends CanvasLayer

#Exit application
func _on_exit_button_pressed() -> void:
	get_tree().quit()

#Go back to menu
func _on_new_game_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/StartMenu.tscn")
