extends Node2D

# This is the base item class
# It handles collecting items and lets child item scripts define their own effects

# Called when the player collects this item
func collect():
	# Apply the item's effect, such as adding food, water, or gold
	apply_effect()
	
	# Remove the item from the scene after it has been collected
	queue_free()

# Placeholder function for child scripts to override
# Each specific item should define what happens when it is collected
func apply_effect():
	pass
