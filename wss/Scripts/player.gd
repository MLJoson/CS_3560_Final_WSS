extends Node


#Setting player stats
var MAX_STRENGTH: int = 100
var MAX_FOOD: int = 50
var MAX_WATER: int = 50

var strength: int = 100 #may use this
var food: int = 25
var water: int = 25
var gold: int = 0

func apply_movement_cost(terrain):
	match terrain:
		0: #GRASS
			strength -= 1 
			water -= 0
			food -= 0
			
		1: #DESERT
			strength -= 2
			food -= 2
			water -= 3
			
		2: #MOUNTAIN
			strength -= 3
			food -= 3
			water -= 1
			
		3: #SWAMP
			strength -= 2
			water -= 2
			food -= 2
		4: #TUNDRA
			strength -= 3
			water -= 1
			food -= 1
	#in the event the player goes under
	#punish player if lack of food or water resource 
	if food < 0:
		strength += food
		food = max(food, 0)
	if water < 0:
		strength += water
		water = max(water, 0)
	print("Strenght: ", strength)
	print("Food: ", food)
	print("Water ", water)
	
	#update UI
	get_tree().call_group("ui", "update_ui")
	
	#if the player runs out of strength -> game over
	if strength < 0:
		get_tree().change_scene_to_file("res://Scenes/YouLose.tscn")

#Resets when game resets
func reset():
	strength = 100 #may use this
	food = 25
	water = 25
	gold = 0
