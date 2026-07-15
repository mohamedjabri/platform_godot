extends Area2D

@export var laser_speed: int
@export var laser_damage: int = 100
var direction: int = 1
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	audio_stream_player_2d.play()

func _physics_process(delta: float) -> void:
	position.x += direction * laser_speed * delta

func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()
