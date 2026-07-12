extends Area2D

@onready var game_manager: Node = get_tree().get_first_node_in_group("game_manager")
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var label_animation: AnimationPlayer = $LabelAnimation

func _ready() -> void:
	if SaveManager.is_collected(str(get_path())):
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	game_manager.add_point()
	SaveManager.mark_collected(str(get_path()))
	animation_player.play("pickup")
	label_animation.play("label_animation")
