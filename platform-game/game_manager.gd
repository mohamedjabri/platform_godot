extends Node

var score = 0
@onready var score_label: Label = $Score

func add_point():
	score += 1
	score_label.text = "Coins collected: " + str(score) + "."

func set_score(value: int) -> void:
	score = value
	score_label.text = "Coins collected: " + str(score) + "."
