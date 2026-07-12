extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var game_manager = %GameManager

func _ready() -> void:
	SaveManager.apply_to_level(player, game_manager)
