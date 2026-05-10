extends "res://Scripts/item.gd"

func apply_effect():
	Player.food += 10
	
func get_item_type():
	return "food"
