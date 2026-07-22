extends Node2D

@export var snake_health: int = 150


func take_damage(amount: int) -> void:
	snake_health = max(snake_health - amount, 0)
	if snake_health <= 0:
		print("killed_it")
