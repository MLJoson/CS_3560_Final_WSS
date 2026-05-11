extends Node2D

class_name BaseTrader

func evaluate_trade(gold_offered, requested_food, requested_water):
	return {
		"accepted": false,
		"counter_gold": gold_offered,
		"counter_food": requested_food,
		"counter_water": requested_water
	}
