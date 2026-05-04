extends CanvasLayer

@onready var strength_label = $VBoxContainer/StrengthLabel
@onready var food_label = $VBoxContainer/FoodLabel
@onready var water_label = $VBoxContainer/WaterLabel
@onready var gold_label = $VBoxContainer/GoldLabel

func _ready():
	add_to_group("ui")
	update_ui()

func update_ui():
	strength_label.text = "Strength: " + str(Player.strength)
	food_label.text = "Food: " + str(Player.food)
	water_label.text = "Water: " + str(Player.water)
	gold_label.text = "Gold: " + str(Player.gold)
