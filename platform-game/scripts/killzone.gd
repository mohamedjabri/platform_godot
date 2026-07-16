extends Area2D

@onready var timer: Timer = $Timer
@export var damage: int = 0

func _on_body_entered(body: Node2D) -> void:
	if damage > 0:
		body.take_damage(damage, true)
	else:
		body.take_damage(body.max_health)
		body.get_node("CollisionShape2D").queue_free()
		timer.start()


func _on_timer_timeout() -> void:
	SaveManager.respawn()
