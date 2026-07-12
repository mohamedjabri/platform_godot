extends Node

# Autoload (Project Settings > Autoload). Lives for the whole app session and
# survives scene changes, so it's the single source of truth for "what game
# are we currently playing" and "what's saved on disk."

const SAVE_DIR := "user://saves/"
const SLOT_COUNT := 3
const GAME_SCENE := "res://scenes/game.tscn"
const MAIN_MENU_SCENE := "res://scenes/main_menu.tscn"


# True once a game is actually in progress (after New Game or Load Game).
# Used by the main menu to decide whether "Save Game" makes sense yet.
var has_active_session: bool = false
var music_volume: float = 0.3
var sfx_volume: float = 0.5
var settings: Dictionary = {}

# The in-memory snapshot of the current playthrough. Shape:
# {
#   "position": [x, y] or null,
#   "health": int or null,
#   "score": int,
#   "collected": [ "path/to/node", ... ],
#   "timestamp": "2026-07-06 12:00:00" (only set once saved)
# }
var current_data: Dictionary = {}
var checkpoint_data: Dictionary = {}


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	load_settings()
	
func load_settings() -> void:
	var file := FileAccess.open(settings_path(), FileAccess.READ)
	if file:
		var data = JSON.parse_string(file.get_as_text())
		file.close()
		
		if typeof(data) != TYPE_DICTIONARY:
			return
		
		settings = data
		music_volume = settings.get("music_volume", music_volume)
		sfx_volume = settings.get("sfx_volume", sfx_volume)
		

func save_settings() -> void:
	settings = {
		"music_volume": music_volume,
		"sfx_volume": sfx_volume
	}
	var file := FileAccess.open(settings_path(), FileAccess.WRITE)
	file.store_string(JSON.stringify(settings))
	file.close()
	
func settings_path() -> String:
	return SAVE_DIR + "settings.save"

func slot_path(slot: int) -> String:
	return SAVE_DIR + "slot_%d.save" % slot


func slot_exists(slot: int) -> bool:
	return FileAccess.file_exists(slot_path(slot))


# Lightweight read used by the UI to show "Empty" vs a summary in each slot
# button, without committing to actually loading that slot.
func slot_info(slot: int) -> Dictionary:
	if not slot_exists(slot):
		return {"empty": true}

	var file := FileAccess.open(slot_path(slot), FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()

	if typeof(data) != TYPE_DICTIONARY:
		return {"empty": true}

	return {
		"empty": false,
		"score": data.get("score", 0),
		"health": data.get("health", 0),
		"timestamp": data.get("timestamp", ""),
	}


# Starts a brand new session. The level's own authored defaults (player
# spawn position, full health, no items collected) are used as-is, so there's
# nothing to restore here beyond resetting our own bookkeeping.
func new_game() -> void:
	current_data = {
		"position": null,
		"health": null,
		"score": 0,
		"collected": [],
	}
	checkpoint_data = current_data.duplicate(true)
	has_active_session = true
	get_tree().change_scene_to_file(GAME_SCENE)


# Loads a save file into memory and jumps to the game scene. The actual
# restoring onto the Player/GameManager happens in apply_to_level(), called
# by the game scene's own _ready(), once those nodes exist.
func load_game(slot: int) -> void:
	if not slot_exists(slot):
		return

	var file := FileAccess.open(slot_path(slot), FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()

	if typeof(data) != TYPE_DICTIONARY:
		return

	current_data = data
	checkpoint_data = current_data.duplicate(true)
	has_active_session = true
	get_tree().change_scene_to_file(GAME_SCENE)


# Writes the current session to disk. If live player/game_manager nodes are
# passed (i.e. you're calling this from inside a running game), their
# current state is captured first so the save is fresh. If not, whatever is
# already in current_data (e.g. right after a Load) is written as-is.
func save_game(slot: int, player: Node = null, game_manager: Node = null) -> void:
	if not has_active_session:
		return

	if player != null:
		record_from_level(player, game_manager)

	current_data["timestamp"] = Time.get_datetime_string_from_system()

	var file := FileAccess.open(slot_path(slot), FileAccess.WRITE)
	file.store_string(JSON.stringify(current_data))
	file.close()
	
	checkpoint_data = current_data.duplicate(true)


# Pulls live values off the player/game_manager into current_data, without
# writing anything to disk yet.
func record_from_level(player: Node, game_manager: Node) -> void:
	current_data["position"] = [player.global_position.x, player.global_position.y]
	current_data["health"] = player.current_health
	if game_manager != null:
		current_data["score"] = game_manager.score


# Called once by the game scene's own _ready(). Applies whatever is in
# current_data onto the freshly loaded level. Safe to call even if nothing
# was ever loaded (e.g. running game.tscn directly in the editor) since it
# just no-ops when there's no active session.
func apply_to_level(player: Node, game_manager: Node) -> void:
	if not has_active_session:
		return
	player.apply_save_data(current_data)
	if game_manager != null:
		game_manager.set_score(current_data.get("score", 0))


# --- Collected-item tracking -------------------------------------------
# Each coin/fruit registers itself here by its own scene-tree path (a
# stable, unique id since the level is hand-authored, not procedural).

func mark_collected(id: String) -> void:
	if not current_data.has("collected"):
		current_data["collected"] = []
	if id not in current_data["collected"]:
		current_data["collected"].append(id)


func is_collected(id: String) -> bool:
	return current_data.has("collected") and id in current_data["collected"]
	
# Called on player death: discards any progress made since the last
# checkpoint (new game start, last load, or last save) and reloads the level.
func respawn() -> void:
	current_data = checkpoint_data.duplicate(true)
	get_tree().reload_current_scene()
