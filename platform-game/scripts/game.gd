extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var game_manager = %GameManager
@onready var fade_in: AnimationPlayer = $FadeCanvas/FadeIn

func _ready() -> void:
	DeathMusic.stop()
	Music.play()
	print(player.global_position)
	if SaveManager.current_data["current_level"]["position"] == null:
		player.play_intro(player.global_position - Vector2(200, 0), 200, 2)
		fade_in.play("fade_in")
		
	SaveManager.apply_to_level(player, game_manager)
