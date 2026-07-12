extends Area2D

@export var heal_amt: int = 20
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	if SaveManager.is_collected(str(get_path())):
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	body.heal(heal_amt)
	SaveManager.mark_collected(str(get_path()))
	animation_player.play("eating")
