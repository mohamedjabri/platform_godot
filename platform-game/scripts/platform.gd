extends AnimatableBody2D
@onready var platform_sprite: Sprite2D = $Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var level: int = SaveManager.current_data["current_level"]["index"]
	platform_sprite.region_rect = Rect2(17, 16 * level, 31, 9)
		
