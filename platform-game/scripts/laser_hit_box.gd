extends Area2D


func _on_area_entered(area: Area2D) -> void:
	var laser = area
	owner.take_damage(laser.laser_damage)
	laser.queue_free()
