extends Control

# Runs when the button is pressed
# Sends the player back to the start menu scene
func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/StartMenu.tscn")
