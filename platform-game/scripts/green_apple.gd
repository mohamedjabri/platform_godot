extends Area2D

@export var heal_amt: int = 20
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	if SaveManager.is_collected(str(get_path())):
		queue_free()
	var level: int = SaveManager.current_data["current_level"]["index"]
	sprite_2d.region_rect = Rect2(0, 16 * level, 16, 17)

func _on_body_entered(body: Node2D) -> void:
	body.heal(heal_amt)
	SaveManager.mark_collected(str(get_path()))
	animation_player.play("eating")
