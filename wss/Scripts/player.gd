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
			water -= 1
			food -= 1
			
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
		
	#in the event the player goes under
	strength = max(strength, 0)
	food = max(food, 0)
	water = max(water, 0)
	print("Strenght: ", strength)
	print("Food: ", food)
	print("Water ", water)


#Resets when game resets
func reset():
	strength = 100 #may use this
	food = 25
	water = 25
	gold = 0
