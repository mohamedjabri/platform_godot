extends Area2D

func _on_area_entered(area: Area2D) -> void:
	var player = area.get_parent()
	if player.velocity.y > 0:
		get_parent().take_damage(player.jump_damage)
		
	player.velocity.y = -300
	player.get_node("JumpSound").play()
