extends CanvasLayer

# References to the UI labels that display the player's current stats
@onready var strength_label = $VBoxContainer/StrengthLabel
@onready var food_label = $VBoxContainer/FoodLabel
@onready var water_label = $VBoxContainer/WaterLabel
@onready var gold_label = $VBoxContainer/GoldLabel

# Runs when the UI is loaded into the scene
func _ready():
	# Add this UI node to the "ui" group so other scripts can call update_ui()
	add_to_group("ui")
	
	# Display the player's starting stats immediately
	update_ui()

# Updates the text shown on each stat label
func update_ui():
	strength_label.text = "Strength: " + str(Player.strength)
	food_label.text = "Food: " + str(Player.food)
	water_label.text = "Water: " + str(Player.water)
	gold_label.text = "Gold: " + str(Player.gold)
