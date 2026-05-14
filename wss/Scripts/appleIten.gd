extends "res://Scripts/item.gd"

# Applies this item's effect when it is used
# This food item increases the player's food supply by 10
func apply_effect():
	Player.food += 10

# Returns the type/category of this item
# Other scripts can use this to identify it as a food item
func get_item_type():
	return "food"
