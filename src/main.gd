extends Control
## Composition point: reads the island and tide configs, picks the runtime
## seed, generates the island and gives it to the view, and runs the tide
## clock that fails the run at full tide.
## Implements design/game-brief.md MVP feature 1 (story-001-island-generation)
## and MVP feature 3 (story-003-tide-timer).

const ISLAND_CONFIG_PATH: String = "res://assets/data/island_config.json"
const TIDE_CONFIG_PATH: String = "res://assets/data/tide_config.json"
const NUMBER_KEYS: Array[String] = [
	"columns", "rows", "edge_margin", "land_fill_ratio", "compactness",
]
const WHOLE_NUMBER_KEYS: Array[String] = ["columns", "rows", "edge_margin"]
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
	if island_config.is_empty() or tide_config.is_empty():
		set_process(false)
		return
	randomize()
	var island_seed: int = randi()
	print("Island seed: ", island_seed)
	_island_view.set_grid(IslandGenerator.generate(island_seed, island_config))

	_tide_timer = TideTimer.new(_tide_seconds_override(float(tide_config["full_tide_seconds"])))
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
