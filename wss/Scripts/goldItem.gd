extends "res://Scripts/item.gd"

func apply_effect():
	Player.gold += 1

func get_item_type():
	return "gold"
