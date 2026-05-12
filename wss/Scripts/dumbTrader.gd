extends "res://Scripts/Trader.gd"

#accepts any offer (truly is a dummy)
func evaluate_trade(gold_offered, requested_food, requested_water):
	var value_requested = requested_food * 0.5 + requested_water * 0.5
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
