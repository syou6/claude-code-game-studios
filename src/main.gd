extends Control
## Composition point: reads the island config, picks the runtime seed,
## generates the island and gives it to the view.
## Implements design/game-brief.md MVP feature 1 (story-001-island-generation).

const CONFIG_PATH: String = "res://assets/data/island_config.json"
const NUMBER_KEYS: Array[String] = [
	"columns", "rows", "edge_margin", "land_fill_ratio", "compactness",
]
const WHOLE_NUMBER_KEYS: Array[String] = ["columns", "rows", "edge_margin"]

@onready var _island_view: IslandView = $IslandView


func _ready() -> void:
	var config: Dictionary = _load_config()
	if config.is_empty():
		return
	randomize()
	var island_seed: int = randi()
	print("Island seed: ", island_seed)
	_island_view.set_grid(IslandGenerator.generate(island_seed, config))


# Reads and validates the JSON at the data-file boundary. Returns {} (after
# pushing an error) when the file is missing or invalid.
func _load_config() -> Dictionary:
	if not FileAccess.file_exists(CONFIG_PATH):
		push_error("Island config not found: %s" % CONFIG_PATH)
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(CONFIG_PATH))
	if not parsed is Dictionary:
		push_error("Island config is not a JSON object: %s" % CONFIG_PATH)
		return {}
	var config: Dictionary = parsed
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
