extends Node

#Setting player stats
var MAX_STRENGTH: int = 100
var MAX_FOOD: int = 100
var MAX_WATER: int = 100

var strength: int = 100 #may use this
var food: int = 25
var water: int = 25
var gold: int = 0

#player states
var isMoving = false
var idleTimer := 0.0
var idleRegenTime := 5.0

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
	food = 100
	water = 100
	gold = 0

#To gain strength
#rule: gain 5 strength for every 5 seconds but lose 1 food and water
func _process(delta):
	if isMoving:
		idleTimer = 0.0
		return
	idleTimer += delta
	if idleTimer >= idleRegenTime:
		idleTimer = 0.0
		# consume supplies
		food -= 1
		water -= 1
		# restore strength
		strength += 5
		strength = min(strength, MAX_STRENGTH)
		# starvation/dehydration punishment
		if food < 0:
			strength += food
			food = max(food, 0)
		if water < 0:
			strength += water
			water = max(water, 0)
		print("Rested -> Strength:", strength)
		get_tree().call_group("ui", "update_ui")
		#lose condition
		if strength <= 0:
			get_tree().change_scene_to_file("res://Scenes/YouLose.tscn")
