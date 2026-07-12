extends CanvasLayer

@onready var slot_picker: Panel = $SlotPicker
@onready var player: CharacterBody2D = %Player
@onready var game_manager = %GameManager
@onready var confirmation_label: Label = $ConfirmationLabel
@onready var main_panel: Panel = $MainPanel

func _ready() -> void:
	main_panel.visible = false
	slot_picker.visible = false
	confirmation_label.visible = false
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused:
			_resume()
		else:
			_open_pause_menu()

func _open_pause_menu() -> void:
	get_tree().paused = true
	main_panel.visible = true
	slot_picker.visible = false

func _resume() -> void:
	get_tree().paused = false
	main_panel.visible = false
	slot_picker.visible = false
	
func _on_slot_1_pressed() -> void:
	_save_and_confirm(1)

func _on_slot_2_pressed() -> void:
	_save_and_confirm(2)

func _on_slot_3_pressed() -> void:
	_save_and_confirm(3)

func _on_save_game_button_pressed() -> void:
	main_panel.visible = false
	slot_picker.visible = true
	
func _save_and_confirm(slot: int) -> void:
	SaveManager.save_game(slot, player, game_manager)
	slot_picker.visible = false
	confirmation_label.text = "Game Saved!"
	confirmation_label.visible = true
	await get_tree().create_timer(1.5).timeout
	confirmation_label.visible = false
	main_panel.visible = true

func _on_resume_button_pressed() -> void:
	_resume()

func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(SaveManager.MAIN_MENU_SCENE)
