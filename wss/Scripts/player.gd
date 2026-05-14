extends Node

# Stores the player's maximum stat values
# These are used to prevent stats like strength, food, and water from going too high
var MAX_STRENGTH: int = 100
var MAX_FOOD: int = 100
var MAX_WATER: int = 100

# Current player stats
var strength: int = 100
var food: int = 25
var water: int = 25
var gold: int = 0

# Player movement/resting state
# isMoving tracks whether the player is currently moving
# idleTimer tracks how long the player has been standing still
# idleRegenTime controls how often the player regains strength while resting
var isMoving = false
var idleTimer := 0.0
var idleRegenTime := 3.0

# Applies stat costs based on the type of terrain the player moves onto
func apply_movement_cost(terrain):
	match terrain:
		0: # Grass terrain has the lowest movement cost
			strength -= 1
			water -= 0
			food -= 0
			
		1: # Desert terrain costs more food and water
			strength -= 2
			food -= 2
			water -= 3
			
		2: # Mountain terrain costs the most strength and food
			strength -= 3
			food -= 3
			water -= 1
			
		3: # Swamp terrain drains all main survival stats evenly
			strength -= 2
			water -= 2
			food -= 2
		
		4: # Tundra terrain costs more strength, plus some food and water
			strength -= 3
			water -= 1
			food -= 1

	# If food goes below 0, subtract the missing food amount from strength
	# Then reset food back to 0 so it does not stay negative
	if food < 0:
		strength += food
		food = max(food, 0)

	# If water goes below 0, subtract the missing water amount from strength
	# Then reset water back to 0 so it does not stay negative
	if water < 0:
		strength += water
		water = max(water, 0)

	# Print the player's current stats for debugging
	print("Strength: ", strength)
	print("Food: ", food)
	print("Water: ", water)
	
	# Update the UI after the player's stats change
	get_tree().call_group("ui", "update_ui")
	
	# If the player runs out of strength, switch to the losing scene
	if strength < 0:
		get_tree().change_scene_to_file("res://Scenes/YouLose.tscn")

# Resets the player's stats when starting a new game
func reset():
	strength = 100
	food = 100
	water = 100
	gold = 0

# Runs every frame
# Used here to restore strength when the player is standing still
func _process(delta):
	# If the player is moving, reset the idle timer and do not restore strength
	if isMoving:
		idleTimer = 0.0
		return

	# Count how long the player has been idle
	idleTimer += delta

	# Once the player has been idle long enough, restore strength
	if idleTimer >= idleRegenTime:
		idleTimer = 0.0

		# Resting consumes food and water
		food -= 1
		water -= 1

		# Restore strength, but do not allow it to go above the maximum
		strength += 5
		strength = min(strength, MAX_STRENGTH)

		# If food goes below 0, punish the player by reducing strength
		if food < 0:
			strength += food
			food = max(food, 0)

		# If water goes below 0, punish the player by reducing strength
		if water < 0:
			strength += water
			water = max(water, 0)

		# Print the resting result for debugging
		print("Rested -> Strength:", strength)

		# Update the UI after resting changes the player's stats
		get_tree().call_group("ui", "update_ui")

		# If strength reaches 0 or less, switch to the losing scene
		if strength <= 0:
			get_tree().change_scene_to_file("res://Scenes/YouLose.tscn")
