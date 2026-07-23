extends Node2D

@export var snake_health: int = 150


func take_damage(amount: int) -> void:
	snake_health = max(snake_health - amount, 0)
	if snake_health <= 0:
		get_node("Path2D/PathFollow2D/AnimatedSprite2D").queue_free()
		get_node("Path2D/PathFollow2D/Killzone").queue_free()
		get_node("Path2D/PathFollow2D/LaserHitBox").queue_free()
