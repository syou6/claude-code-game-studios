extends Control
## Composition point: reads the island, tide and items configs, picks the
## runtime seed, generates the island (land and contents) and gives it to the
## view, wires the dig system to the tide clock, and runs the tide clock that
## fails the run at full tide.
## Implements design/game-brief.md MVP feature 1 (story-001-island-generation),
## MVP feature 3 (story-003-tide-timer) and the composition of MVP feature 4
## (story-004-treasures-and-trap).

const ISLAND_CONFIG_PATH: String = "res://assets/data/island_config.json"
const TIDE_CONFIG_PATH: String = "res://assets/data/tide_config.json"
const ITEMS_CONFIG_PATH: String = "res://assets/data/items.json"
const NUMBER_KEYS: Array[String] = [
	"columns", "rows", "edge_margin", "land_fill_ratio", "compactness",
]
const WHOLE_NUMBER_KEYS: Array[String] = ["columns", "rows", "edge_margin"]
## Number of treasure kinds items.json must define (brief: 3種類の宝).
const TREASURE_KIND_COUNT: int = 3
## Debug/testing only. A user argument `--tide-seconds=<float>` (after `--` on
## the command line, e.g. `godot --path . -- --tide-seconds=10`) overrides
## full_tide_seconds for one run, so a full tide can be observed in seconds.
const TIDE_SECONDS_ARG_PREFIX: String = "--tide-seconds="

@onready var _island_view: IslandView = $IslandView

var _tide_timer: TideTimer
var _run_state: RunState
var _tide_gauge: TideGauge


func _ready() -> void:
	var island_config: Dictionary = _load_island_config()
	var tide_config: Dictionary = _load_tide_config()
	var items_config: Dictionary = _load_items_config()
	if island_config.is_empty() or tide_config.is_empty() or items_config.is_empty():
		set_process(false)
		return
	randomize()
	var island_seed: int = randi()
	print("Island seed: ", island_seed)
	_island_view.set_grid(
		IslandGenerator.generate(island_seed, island_config, TreasureTable.new(items_config)))

	_tide_timer = TideTimer.new(_tide_seconds_override(float(tide_config["full_tide_seconds"])))
	# The dig system is composed here so a dug trap can reach the tide clock.
	# IslandView's _ready has already run (children first), so this replaces
	# the default it made; set_dig_system always takes the injected one.
	var dig_system := DigSystem.new()
	dig_system.set_tide_timer(_tide_timer)
	_island_view.set_dig_system(dig_system)
	_run_state = RunState.new()
	_run_state.phase_changed.connect(_on_phase_changed)
	_island_view.set_run_state(_run_state)

	# The gauge is created here, not in main.tscn: a full-height strip on the
	# left edge. The island view is pushed right by the same width so the gauge
	# never covers a tile; the gauge also ignores mouse input (see TideGauge).
	_island_view.offset_left = TideGauge.WIDTH
	_tide_gauge = TideGauge.new()
	_tide_gauge.anchor_bottom = 1.0
	_tide_gauge.offset_right = TideGauge.WIDTH
	add_child(_tide_gauge)


# The tide advances only by the frame delta passed in here. When the OS
# suspends the app and the engine stops ticking, the tide simply stops and
# resumes where it was on return; nothing reads a real clock, so the state
# cannot jump or break while backgrounded (story 003, AC 8).
func _process(delta: float) -> void:
	if not _run_state.can_dig():
		return
	_tide_timer.advance(delta)
	_run_state.update_from_tide(_tide_timer)
	_tide_gauge.set_level(_tide_timer.get_level())


func _on_phase_changed(new_phase: RunState.Phase) -> void:
	_tide_gauge.set_failed(new_phase == RunState.Phase.FAILED)


# Debug/testing only (see TIDE_SECONDS_ARG_PREFIX). Returns `default_seconds`
# unless the override argument is present and holds a number > 0.
func _tide_seconds_override(default_seconds: float) -> float:
	for arg: String in OS.get_cmdline_user_args():
		if not arg.begins_with(TIDE_SECONDS_ARG_PREFIX):
			continue
		var value: String = arg.trim_prefix(TIDE_SECONDS_ARG_PREFIX)
		if value.is_valid_float() and float(value) > 0.0:
			print("Full tide overridden to %s seconds (debug argument)." % value)
			return float(value)
		push_warning("Ignoring '%s': value must be a number > 0." % arg)
	return default_seconds


# Reads a JSON object file at the data-file boundary. Returns {} (after
# pushing an error) when the file is missing or is not a JSON object.
func _read_json_object(path: String, label: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("%s config not found: %s" % [label, path])
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not parsed is Dictionary:
		push_error("%s config is not a JSON object: %s" % [label, path])
		return {}
	var config: Dictionary = parsed
	return config


# Validates island_config.json. Returns {} (after pushing an error) on bad data.
func _load_island_config() -> Dictionary:
	var config: Dictionary = _read_json_object(ISLAND_CONFIG_PATH, "Island")
	if config.is_empty():
		return {}
	for key: String in NUMBER_KEYS:
		if not (config.get(key) is float or config.get(key) is int):
			push_error("Island config: '%s' must be a number." % key)
			return {}
	for key: String in WHOLE_NUMBER_KEYS:
		if float(config[key]) != floorf(float(config[key])):
			push_error("Island config: '%s' must be a whole number." % key)
			return {}
	var columns: int = int(config["columns"])
	var rows: int = int(config["rows"])
	var margin: int = int(config["edge_margin"])
	var fill_ratio: float = float(config["land_fill_ratio"])
	if margin < 1 or columns <= 2 * margin or rows <= 2 * margin:
		push_error("Island config: need edge_margin >= 1 and columns/rows > 2 * edge_margin.")
		return {}
	if fill_ratio <= 0.0 or fill_ratio > 1.0:
		push_error("Island config: land_fill_ratio must be in (0, 1].")
		return {}
	if float(config["compactness"]) < 0.0:
		push_error("Island config: compactness must be >= 0.")
		return {}
	return config


# Validates tide_config.json. Returns {} (after pushing an error) on bad data.
func _load_tide_config() -> Dictionary:
	var config: Dictionary = _read_json_object(TIDE_CONFIG_PATH, "Tide")
	if config.is_empty():
		return {}
	var seconds: Variant = config.get("full_tide_seconds")
	if not (seconds is float or seconds is int) or float(seconds) <= 0.0:
		push_error("Tide config: 'full_tide_seconds' must be a number > 0.")
		return {}
	return config


# Validates items.json (schema: assets/data/items.md). Returns {} (after
# pushing an error) on bad data, so TreasureTable can index it without checks.
func _load_items_config() -> Dictionary:
	var config: Dictionary = _read_json_object(ITEMS_CONFIG_PATH, "Items")
	if config.is_empty():
		return {}

	if not config.get("spawn_weights") is Dictionary:
		push_error("Items config: 'spawn_weights' must be an object.")
		return {}
	var spawn_weights: Dictionary = config["spawn_weights"]
	var any_kind_weight: bool = false
	for key: String in TreasureTable.KIND_KEYS:
		if not _is_weight(spawn_weights.get(key)):
			push_error("Items config: spawn_weights.%s must be a number >= 0." % key)
			return {}
		any_kind_weight = any_kind_weight or float(spawn_weights[key]) > 0.0
	if not any_kind_weight:
		push_error("Items config: at least one spawn_weights entry must be > 0.")
		return {}

	if not config.get("treasures") is Array or (config["treasures"] as Array).size() != TREASURE_KIND_COUNT:
		push_error("Items config: 'treasures' must be a list of exactly %d entries." % TREASURE_KIND_COUNT)
		return {}
	var treasures: Array = config["treasures"]
	var values: Array[int] = []
	var any_treasure_weight: bool = false
	for i: int in treasures.size():
		if not treasures[i] is Dictionary:
			push_error("Items config: treasures[%d] must be an object." % i)
			return {}
		var entry: Dictionary = treasures[i]
		var label: String = "treasures[%d]" % i
		if not _has_valid_id(entry, label):
			return {}
		var value: Variant = entry.get("value")
		if not _is_number(value) or float(value) <= 0.0 or float(value) != floorf(float(value)):
			push_error("Items config: %s.value must be a whole number > 0." % label)
			return {}
		if values.has(int(value)):
			push_error("Items config: the %d treasure values must all differ." % TREASURE_KIND_COUNT)
			return {}
		values.append(int(value))
		if not _is_weight(entry.get("weight")):
			push_error("Items config: %s.weight must be a number >= 0." % label)
			return {}
		any_treasure_weight = any_treasure_weight or float(entry["weight"]) > 0.0
	if not any_treasure_weight:
		push_error("Items config: at least one treasures[].weight must be > 0.")
		return {}

	if not config.get("trap") is Dictionary:
		push_error("Items config: 'trap' must be an object.")
		return {}
	var trap: Dictionary = config["trap"]
	if not _has_valid_id(trap, "trap"):
		return {}
	var tide_seconds: Variant = trap.get("tide_seconds")
	if not _is_number(tide_seconds) or float(tide_seconds) <= 0.0:
		push_error("Items config: trap.tide_seconds must be a number > 0.")
		return {}

	if not config.get("tool") is Dictionary:
		push_error("Items config: 'tool' must be an object.")
		return {}
	if not _has_valid_id(config["tool"], "tool"):
		return {}
	return config


# Checks that `entry` has a non-empty string `id`. `label` names the entry in
# the error message.
func _has_valid_id(entry: Dictionary, label: String) -> bool:
	if not entry.get("id") is String or (entry["id"] as String).is_empty():
		push_error("Items config: %s.id must be a non-empty string." % label)
		return false
	return true


func _is_number(value: Variant) -> bool:
	return value is float or value is int


# A spawn weight: any non-negative number (zero disables that entry).
func _is_weight(value: Variant) -> bool:
	return _is_number(value) and float(value) >= 0.0
