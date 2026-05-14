extends Node2D

# Gives this script a global class name
# Other scripts can check if something is a BaseTrader
class_name BaseTrader

# Base trade function
# Child trader scripts should override this with their own trade logic
func evaluate_trade(gold_offered, requested_food, requested_water):
	# Default trade response
	# The base trader rejects the trade and returns the same values as a counteroffer
	return {
		"accepted": false,
		"counter_gold": gold_offered,
		"counter_food": requested_food,
		"counter_water": requested_water
	}
