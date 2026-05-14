extends CanvasLayer

# Stores the trader this menu is currently interacting with
var trader = null

# Stores the most recent trade result
# This is used when the player presses the accept button
var pending_trade = null

# Text boxes where the player enters their trade offer
@onready var gold_input = $Panel/goldTextbox
@onready var food_input = $Panel/foodTextbox
@onready var water_input = $Panel/waterTextbox

# Label used to show trade messages, such as errors or counteroffers
@onready var status_label = $Panel/statusLabel

# Button used to accept a trade after the trader agrees
@onready var accept_button = $Panel/acceptButton

# Sets which trader this menu is trading with
func set_trader(t):
	trader = t

# Runs when the player presses the offer button
func _on_offer_button_pressed() -> void:
	# Read the player's offer from the input boxes
	var gold = int(gold_input.text)
	var food = int(food_input.text)
	var water = int(water_input.text)
	
	# Do not allow negative trade values
	if gold < 0 or food < 0 or water < 0:
		return
	
	# Make sure the player is not offering more gold than they have
	if gold > Player.gold:
		status_label.text = "Not enough gold!"
		return
	
	# Ask the trader to evaluate the offer
	var result = trader.evaluate_trade(gold, food, water)
	
	# Store the result so it can be used if the player accepts
	pending_trade = result
	
	# If the trader accepts, enable the accept button
	if result.accepted:
		status_label.text = "Trader accepts!"
		accept_button.disabled = false
	
	# If the trader rejects the offer, show the counteroffer
	else:
		status_label.text = "Counter offer proposed."
		gold_input.text = str(result.counter_gold)
		food_input.text = str(result.counter_food)
		water_input.text = str(result.counter_water)
		accept_button.disabled = true

# Runs when the player accepts an approved trade
func _on_accept_button_pressed() -> void:
	# Do nothing if there is no trade waiting to be accepted
	if pending_trade == null:
		return
	
	# Read the final accepted trade values
	var gold = int(gold_input.text)
	var food = int(food_input.text)
	var water = int(water_input.text)
	
	# Remove the offered gold from the player
	Player.gold -= gold
	
	# Add the requested food and water to the player
	Player.food += food
	Player.water += water
	
	# Update the stats UI after the trade
	get_tree().call_group("ui", "update_ui")
	
	# Close the trading menu
	close_menu()

# Runs when the exit button is pressed
func _on_exit_button_pressed() -> void:
	close_menu()

# Closes the menu and unpauses the game
func close_menu():
	get_tree().paused = false
	queue_free()
