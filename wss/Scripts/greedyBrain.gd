extends "res://Scripts/theBrain.gd"

# Returns the type of item this brain wants the character to look for
# In this case, the character will prioritize gold items
func get_desired_item_type():
	return "gold"
