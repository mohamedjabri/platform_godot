extends Area2D


func _on_area_entered(area: Area2D) -> void:
	var laser = area
	get_parent().take_damage(laser.laser_damage)
	laser.queue_free()
