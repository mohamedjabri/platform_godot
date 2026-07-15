extends Area2D
@onready var audio_stream_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	if SaveManager.is_key_collected():
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	body.has_key = true
	animation_player.play("pick_up")
	SaveManager.mark_key_collected()
	audio_stream_player.play()
