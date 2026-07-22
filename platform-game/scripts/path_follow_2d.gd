@tool

extends PathFollow2D
@export var factor: int = 50
@export var process: bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	if process:
		progress += delta * factor
