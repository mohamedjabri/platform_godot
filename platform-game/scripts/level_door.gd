extends AnimatableBody2D
@onready var open_door: AnimationPlayer = $OpenDoor
@onready var open_door_collision: CollisionShape2D = $Area2D/OpenDoorCollision

var is_open: bool = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_key and not is_open:
		is_open = true
		open_door.play("open_door")
		await open_door.animation_finished


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.has_key and is_open:
		is_open = false
		open_door.play("close_door")
		await open_door.animation_finished
