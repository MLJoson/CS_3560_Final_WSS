extends "res://Scripts/item.gd"

# Applies this item's effect when it is used or collected
# This water item increases the player's water supply by 10
func apply_effect():
	Player.water += 10

# Returns the type/category of this item
# Other scripts can use this to identify it as a water item
func get_item_type():
	return "water"
