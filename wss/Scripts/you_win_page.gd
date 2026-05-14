extends CanvasLayer

# Runs when the exit button is pressed
# Closes the game/application
func _on_exit_button_pressed() -> void:
	get_tree().quit()

# Runs when the new game button is pressed
# Sends the player back to the start menu so they can begin again
func _on_new_game_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/StartMenu.tscn")
