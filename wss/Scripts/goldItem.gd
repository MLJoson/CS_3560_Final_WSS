extends "res://Scripts/item.gd"

# Applies this item's effect when it is used or collected
# This gold item increases the player's gold by 1
func apply_effect():
	Player.gold += 1

# Returns the type/category of this item
# Other scripts can use this to identify it as a gold item
func get_item_type():
	return "gold"
