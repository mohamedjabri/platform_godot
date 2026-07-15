extends AnimatableBody2D

var popped: bool = false
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	popped = SaveManager.is_popped(str(get_path()))
	if not popped:
		animation_player.play("quest_on")


func _on_area_2d_body_entered(_body: Node2D) -> void:
	if not popped:
		SaveManager.mark_is_popped(str(get_path()))
		animation_player.play("box_hit")
		await animation_player.animation_finished
		animation_player.play("key_up")
