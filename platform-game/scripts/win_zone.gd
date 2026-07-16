extends Area2D
@onready var game_manager: Node = %GameManager
@onready var info_label: Label = %InfoLabel
@onready var panel: Panel = %Panel
@onready var game_finished: AudioStreamPlayer = %GameFinished
@onready var panel_fade: AnimationPlayer = %PanelFade
@onready var next_level: Button = %NextLevel
var level_finished: bool = false

func advance_game(current_data: Dictionary) -> Dictionary:
	return  {
		"current_level": {
			"index": current_data["current_level"]["index"] + 1,
			"position": null,
			"health": null,
			"score": current_data["current_level"]["score"],
			"has_key": false,
			"is_popped": {},
			"collected": [],
		},
	}

func _on_body_entered(body: Node2D) -> void:
	if body.has_key:
		level_finished = true
		get_tree().paused = true
		panel_fade.play("fade_panel")
		await panel_fade.animation_finished
		info_label.text = "Score: " + str(game_manager.score) + " ."
		info_label.text += "\n\nCurrent Health: " + str(body.current_health) + " ."
		game_finished.play()
		await game_finished.finished
		
		
	
func _unhandled_input(event: InputEvent) -> void:
	if (event.is_action_pressed("ui_cancel")) and (level_finished == true):
		get_tree().paused = false
		get_tree().change_scene_to_file(SaveManager.MAIN_MENU_SCENE)
	


func _on_next_level_pressed() -> void:
	get_tree().paused = false
	if len(SaveManager.levels)>1:
		SaveManager.current_data = advance_game(SaveManager.current_data)
		SaveManager.checkpoint_data = SaveManager.current_data.duplicate(true)
		get_tree().change_scene_to_file(SaveManager.levels[SaveManager.current_data["current_level"]["index"]])
