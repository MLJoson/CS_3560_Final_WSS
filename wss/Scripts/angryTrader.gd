extends "res://Scripts/Trader.gd"

#more agressive trades via demanding more
func evaluate_trade(gold_offered, requested_food, requested_water):
	var value_requested = requested_food * 2 + requested_water * 2
	var required_gold = value_requested * 2
	
	if gold_offered >= required_gold:
		return {
			"accepted": true,
			"counter_gold": gold_offered,
			"counter_food": requested_food,
			"counter_water": requested_water}
			
	return {
		"accepted": false,
		"counter_gold": required_gold,
		"counter_food": requested_food,
		"counter_water": requested_water}
