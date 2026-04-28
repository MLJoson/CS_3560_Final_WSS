extends Node2D
#This program is the main class for collecting items and updating player stats

#Called when player collects the item
func collect():
	apply_effect()
	queue_free()  # remove item from scene

#To be overridden by child scripts
func apply_effect():
	pass
