class_name TreasureTable
extends RefCounted
## Weighted table of what a LAND tile can hide, built from items.json, and the
## step that fills an IslandGrid with contents. All randomness comes from the
## RandomNumberGenerator passed in, so the same rng state always gives the same
## placement and the table can be unit-tested without a running game.
## Implements design/game-brief.md MVP feature 4 (story-004-treasures-and-trap).

## items.json `spawn_weights` key for each TileContent.Kind, in enum order.
const KIND_KEYS: Array[String] = ["empty", "treasure", "trap", "tool"]

var _kind_weights: Array[float] = []
var _kind_weight_total: float = 0.0
var _treasures: Array[TileContent] = []
var _treasure_weights: Array[float] = []
var _treasure_weight_total: float = 0.0
var _trap: TileContent
var _tool: TileContent


## Builds the table. `config` is the validated items.json dictionary (see
## main.gd): `spawn_weights` (one non-negative weight per KIND_KEYS entry),
## `treasures` (list of {id, value, weight}), `trap` ({id, tide_seconds}) and
## `tool` ({id}).
func _init(config: Dictionary) -> void:
	var spawn_weights: Dictionary = config["spawn_weights"]
	for key: String in KIND_KEYS:
		var weight: float = float(spawn_weights[key])
		_kind_weights.append(weight)
		_kind_weight_total += weight
	var treasures: Array = config["treasures"]
	for entry: Dictionary in treasures:
		var weight: float = float(entry["weight"])
		_treasures.append(TileContent.new(TileContent.Kind.TREASURE, entry["id"], int(entry["value"])))
		_treasure_weights.append(weight)
		_treasure_weight_total += weight
	var trap: Dictionary = config["trap"]
	_trap = TileContent.new(TileContent.Kind.TRAP, trap["id"], 0, float(trap["tide_seconds"]))
	var tool: Dictionary = config["tool"]
	_tool = TileContent.new(TileContent.Kind.TOOL, tool["id"])


## Rolls the contents of one tile: a kind by `spawn_weights`, then for a
## treasure one of the three by its weight. Returns a fresh TileContent each
## call (an EMPTY one for an empty tile).
func pick(rng: RandomNumberGenerator) -> TileContent:
	var kind: TileContent.Kind = _pick_index(_kind_weights, _kind_weight_total, rng) as TileContent.Kind
	match kind:
		TileContent.Kind.TREASURE:
			var template: TileContent = _treasures[
				_pick_index(_treasure_weights, _treasure_weight_total, rng)]
			return TileContent.new(TileContent.Kind.TREASURE, template.id, template.value)
		TileContent.Kind.TRAP:
			return TileContent.new(TileContent.Kind.TRAP, _trap.id, 0, _trap.tide_seconds)
		TileContent.Kind.TOOL:
			return TileContent.new(TileContent.Kind.TOOL, _tool.id)
	return TileContent.new(TileContent.Kind.EMPTY)


## Stores a pick on every LAND tile of `grid`, visiting cells in row-major
## order so the result depends only on the grid and the rng state.
func populate(grid: IslandGrid, rng: RandomNumberGenerator) -> void:
	for y: int in grid.rows:
		for x: int in grid.columns:
			var cell := Vector2i(x, y)
			if grid.is_land(cell):
				grid.set_contents(cell, pick(rng))


# Weighted choice of an index into `weights` (whose sum is `total`). Zero
# weights are never chosen; the last positive weight catches the rounding edge
# where the roll lands exactly on `total`. The caller guarantees total > 0.
static func _pick_index(weights: Array[float], total: float, rng: RandomNumberGenerator) -> int:
	var roll: float = rng.randf() * total
	var chosen: int = 0
	for i: int in weights.size():
		if weights[i] <= 0.0:
			continue
		chosen = i
		if roll < weights[i]:
			break
		roll -= weights[i]
	return chosen
