extends AnimatableBody2D

var rng = RandomNumberGenerator.new()
var popped: bool = false

@export var rigged_chance: float = 0.5
@onready var slime: CharacterBody2D = $Slime
@onready var animation_player: AnimationPlayer = $AnimationPlayer



func _ready() -> void:
	
	popped = SaveManager.is_popped(str(get_path()))
	slime.set_dormant(true)
	slime.visible = false
	if not popped:
		animation_player.play("rainbow")
	
func _on_area_2d_body_entered(_body: Node2D) -> void:
	if not popped:
		SaveManager.mark_is_popped(str(get_path()))
		popped = true
		var rng_f: float = rng.randf()
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
