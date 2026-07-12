extends AnimatableBody2D

var touch_count: int = 0
var rng = RandomNumberGenerator.new()

@export var rigged_chance: float = 0.5
@onready var slime: CharacterBody2D = $Slime
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	slime.set_dormant(true)
	slime.visible = false
	
func _on_area_2d_body_entered(_body: Node2D) -> void:
	touch_count += 1
	var rng_f: float = rng.randf()
	print(rng_f)
	if touch_count == 1:
		animation_player.play("box_hit")
		await  animation_player.animation_finished
		if rng_f >= rigged_chance:
			animation_player.play("coin_appear")
		else:
			animation_player.play("slime_appear")
			slime.visible = true
			await animation_player.animation_finished
			slime.set_dormant(false)
			slime.speed = 30
