extends CanvasLayer

var trader = null
var pending_trade = null

@onready var gold_input = $Panel/goldTextbox
@onready var food_input = $Panel/foodTextbox
@onready var water_input = $Panel/waterTextbox

@onready var status_label = $Panel/statusLabel

@onready var accept_button = $Panel/acceptButton

#get trader type
func set_trader(t):
	trader = t


func _on_offer_button_pressed() -> void:
	var gold = int(gold_input.text)
	var food = int(food_input.text)
	var water = int(water_input.text)
	# player can't offer more gold than owned
	if gold < 0 or food < 0 or water < 0:
		return
	if gold > Player.gold:
		status_label.text = "Not enough gold!"
		return
	var result = trader.evaluate_trade(gold, food, water)
	pending_trade = result
	if result.accepted:
		status_label.text = "Trader accepts!"
		accept_button.disabled = false
	else:
		status_label.text = "Counter offer proposed."
		gold_input.text = str(result.counter_gold)
		food_input.text = str(result.counter_food)
		water_input.text = str(result.counter_water)
		accept_button.disabled = true


func _on_accept_button_pressed() -> void:
	if pending_trade == null:
		return
	var gold = int(gold_input.text)
	var food = int(food_input.text)
	var water = int(water_input.text)
	Player.gold -= gold
	Player.food += food
	Player.water += water
	get_tree().call_group("ui", "update_ui")
	close_menu()


func _on_exit_button_pressed() -> void:
	close_menu()

func close_menu():
	get_tree().paused = false
	queue_free()
