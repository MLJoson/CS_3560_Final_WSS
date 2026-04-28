extends Node

var map_width = 100
var map_height = 20
var difficulty = ""
var vision = ""


#check user intput
func get_valid_size(text):
	#check if it's actually a number
	if not text.is_valid_int():
		return -1
	
	var value = int(text)
	
	# Check range
	if value < 20 or value > 200:
		return -1
	
	return value

func _on_button_pressed() -> void:
	Player.reset()
	var width = get_valid_size($widthText.text)
	var height = get_valid_size($heightText.text)
	
	if width >= 1000 && width <= 20:
		print("Invalid width! Must be 20–1000")
		return
	
	if height >= 1000 && height <= 20:
		print("Invalid height! Must be 20–1000")
		return
	
	Global.map_width = width
	Global.map_height = height
	Global.difficulty = $DifficultyDropdown.get_item_text($DifficultyDropdown.selected)
	Global.vision = $visionDropdown.get_item_text($visionDropdown.selected)
	
	get_tree().change_scene_to_file("res://Scenes/theMap.tscn")
