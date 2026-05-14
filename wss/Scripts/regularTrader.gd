extends "res://Scripts/Trader.gd"

# This trader only accepts fair trades
# Trade rule:
# 1 gold is worth 2 total resources
# That means 1 gold can buy 2 food, 2 water, or 1 food and 1 water
func evaluate_trade(gold_offered, requested_food, requested_water):
	
	# Calculate the total amount of food and water the player is asking for
	var value_requested = requested_food + requested_water
	
	# Calculate the value of the gold being offered
	# Each gold is worth 2 resource units
	var value_given = gold_offered * 2
	
	# Accept the trade if the offered gold is worth at least
	# as much as the requested food and water
	if value_given >= value_requested:
		return {
			"accepted": true,
			"counter_gold": gold_offered,
			"counter_food": requested_food,
			"counter_water": requested_water
		}
	
	# Reject the trade and make a counteroffer
	# ceil() rounds up so the trader always asks for enough gold
	# to cover the requested resources fairly
	return {
		"accepted": false,
		"counter_gold": ceil(value_requested / 2.0),
		"counter_food": requested_food,
		"counter_water": requested_water
	}
