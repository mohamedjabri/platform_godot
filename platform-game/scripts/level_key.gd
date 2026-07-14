extends Area2D

@onready var game_manager: Node = get_tree().get_first_node_in_group("game_manager")


func _ready() -> void:
	if SaveManager.is_key_collected(str(get_path())):
		print("collected")
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	SaveManager.mark_key_collected(str(get_path()))
	print("key collected")
