extends "res://Scripts/Trader.gd"

# Dumb Trader is very easy to trade with (really is a dummy)
# Food and water are valued cheaply, so the required gold is low
func evaluate_trade(gold_offered, requested_food, requested_water):
	# Calculate the base value of the requested resources
	# Each unit of food and water is only worth 0.5 gold
	var value_requested = requested_food * 0.5 + requested_water * 0.5
	
	# Calculate how much gold the trader wants for the requested items
	# Since the base value is low, this trader accepts cheaper trades
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
	# but asks for the minimum required gold
	return {
		"accepted": false,
		"counter_gold": required_gold,
		"counter_food": requested_food,
		"counter_water": requested_water
	}
