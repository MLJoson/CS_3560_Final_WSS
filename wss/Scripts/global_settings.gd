extends Node

# Default map settings
# These values are used before the player chooses custom options
var map_width = 100
var map_height = 20

# Stores the selected game settings from the dropdown menus
var difficulty = ""
var vision = ""
var brain = ""

# Checks if the user's text input is a valid map size
# Returns the number if it is valid
# Returns -1 if the input is not a number or is outside the allowed range
func get_valid_size(text):
	# Make sure the input is actually an integer
	if not text.is_valid_int():
		return -1
	
	var value = int(text)
	
	# Make sure the number is within the allowed map size range
	if value < 20 or value > 200:
		return -1
	
	return value

# Runs when the start/play button is pressed
func _on_button_pressed() -> void:
	# Reset the player before starting a new game
	Player.reset()
	
	# Read and validate the width and height text fields
	var width = get_valid_size($widthText.text)
	var height = get_valid_size($heightText.text)
	
	# Stop if the width input is invalid
	if width == -1:
		print("Invalid width! Must be 20–200")
		return
	
	# Stop if the height input is invalid
	if height == -1:
		print("Invalid height! Must be 20–200")
		return
	
	# Save the selected map size and game options globally
	# so the map scene can use them when it loads
	Global.map_width = width
	Global.map_height = height
	Global.difficulty = $DifficultyDropdown.get_item_text($DifficultyDropdown.selected)
	Global.vision = $visionDropdown.get_item_text($visionDropdown.selected)
	Global.brain = $brainDropdown.get_item_text($brainDropdown.selected)
	
	# Load the main map scene
	get_tree().change_scene_to_file("res://Scenes/theMap.tscn")

# Runs when the exit button is pressed
# Closes the game
func _on_exit_button_pressed() -> void:
	get_tree().quit()

# Runs when the help button is pressed
# Opens the help menu scene
func _on_help_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/helpMenu.tscn")
