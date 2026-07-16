extends Control

@onready var main_buttons: VBoxContainer = $VBoxContainer

@onready var new_game_button: Button = $VBoxContainer/NewGameButton
@onready var load_game_button: Button = $VBoxContainer/LoadGameButton
@onready var exit_game_button: Button = $VBoxContainer/ExitGameButton

@onready var slot_picker: Panel = $SlotPicker
@onready var slot_buttons: Array[Button] = [$SlotPicker/Slot1, $SlotPicker/Slot2, $SlotPicker/Slot3]
@onready var close_button: Button = $SlotPicker/CloseButton
@onready var main_music_slider: HSlider = %MainMusicSlider
@onready var sfx_slider: HSlider = %SFXSlider


func _ready() -> void:
	_refresh_slot_labels()
	main_music_slider.set_value_no_signal(SaveManager.music_volume)
	sfx_slider.set_value_no_signal(SaveManager.sfx_volume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(SaveManager.music_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(SaveManager.sfx_volume))
	
func _refresh_slot_labels() -> void:
	for i in slot_buttons.size():
		var slot := i + 1
		var info := SaveManager.slot_info(slot)
		if info["empty"]:
			slot_buttons[i].text = "Slot %d — Empty" % slot
		else:
			slot_buttons[i].text = "Slot %d — Score %d" % [slot, info["score"]]
			
func _show_slot_picker() -> void:
	main_buttons.visible = false
	slot_picker.visible = true

func _on_new_game_button_pressed() -> void:
	SaveManager.new_game()

func _on_load_game_button_pressed() -> void:
	_refresh_slot_labels()
	_show_slot_picker()

func _on_exit_game_button_pressed() -> void:
	get_tree().quit()
	
func _on_close_button_pressed() -> void:
	slot_picker.visible = false
	main_buttons.visible = true

func _on_slot_1_pressed() -> void:
	_handle_slot_pressed(1)

func _on_slot_2_pressed() -> void:
	_handle_slot_pressed(2)

func _on_slot_3_pressed() -> void:
	_handle_slot_pressed(3)

func _handle_slot_pressed(slot: int) -> void:
	if SaveManager.slot_exists(slot):
		SaveManager.load_game(slot)

func _on_main_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))
	SaveManager.music_volume = value
	SaveManager.save_settings()

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))
	SaveManager.sfx_volume = value
	SaveManager.save_settings()
	
