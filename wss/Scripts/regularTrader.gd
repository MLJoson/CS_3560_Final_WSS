extends "res://Scripts/Trader.gd"

#will working until a fair trade
#1 gold = 2 food or 2 water or 1 of each
func evaluate_trade(gold_offered, requested_food, requested_water):
	
	var value_requested = requested_food + requested_water
	var value_given = gold_offered * 2
	
	if value_given >= value_requested:
		return {
			"accepted": true,
			"counter_gold": gold_offered,
			"counter_food": requested_food,
			"counter_water": requested_water}
			
	return {
		"accepted": false,
		"counter_gold": ceil(value_requested / 2.0),
		"counter_food": requested_food,
		"counter_water": requested_water}
