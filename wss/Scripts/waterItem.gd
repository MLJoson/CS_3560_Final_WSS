extends "res://Scripts/item.gd"

func apply_effect():
	Player.water += 10

func get_item_type():
	return "water"
