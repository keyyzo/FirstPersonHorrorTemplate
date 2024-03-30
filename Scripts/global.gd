extends Node

var Level # Reference to the level
var Player # Reference to the Player

# Preload / Loading objects needed for smooth pickup

@onready var test_pickup_item = preload("res://Scenes/test_pickup_item.tscn")
