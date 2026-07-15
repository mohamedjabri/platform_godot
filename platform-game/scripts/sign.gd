extends Area2D
@onready var key_required_label: Label = $KeyRequiredLabel
@onready var level_complete_label: Label = $LevelCompleteLabel

func _ready() -> void:
	key_required_label.visible = false
	level_complete_label.visible = false
	

func _on_body_entered(body: Node2D) -> void:
	if not body.has_key:
		key_required_label.visible = true
	else:
		level_complete_label.visible = true


func _on_body_exited(body: Node2D) -> void:
	key_required_label.visible = false
	level_complete_label.visible = false
