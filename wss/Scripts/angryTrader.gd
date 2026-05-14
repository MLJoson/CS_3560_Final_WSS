extends "res://Scripts/Trader.gd"

# Angry Trader is more demanding than normal traders
# Angry Trader demands extra gold by valuing the requested food and water,
# then doubling that value to calculate the required payment
func evaluate_trade(gold_offered, requested_food, requested_water):
	# Calculate the base value of the requested resources
	# Each unit of food and water is worth 2 gold
	var value_requested = requested_food * 2 + requested_water * 2
	
	# This trader demands double the base value in gold
	var required_gold = value_requested * 2
	
	# Accept the trade if the player offers enough gold
	if gold_offered >= required_gold:
		return {
			"accepted": true,
			"counter_gold": gold_offered,
			"counter_food": requested_food,
			"counter_water": requested_water
		}
	
	# Reject the trade and make a counteroffer
	# The trader keeps the requested food and water the same,
	# but raises the gold requirement to the required amount
	return {
		"accepted": false,
		"counter_gold": required_gold,
		"counter_food": requested_food,
		"counter_water": requested_water
	}
