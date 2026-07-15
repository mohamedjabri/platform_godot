extends Area2D

@export var destination: Node2D
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	sprite.frame = 0 if destination != null else 1

func _on_body_entered(body: Node2D) -> void:
	if destination != null:
		body.global_position = destination.global_position
