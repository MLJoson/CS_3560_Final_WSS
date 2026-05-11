extends "res://Scripts/Trader.gd"

#accepts any offer (truly is a dummy)
func evaluate_trade(gold_offered, requested_food, requested_water):
	return {
		"accepted": true,
		"counter_gold": gold_offered,
		"counter_food": requested_food,
		"counter_water": requested_water}
