class_name DigSystem
extends RefCounted
## Pure dig logic: converts a position to a grid cell, digs the tiles in the
## dig range around a tapped cell and applies what each dug tile reveals (a
## treasure joins the inventory, a trap raises the tide). No scene, node or
## singleton dependency, so it can be unit-tested without a running game.
## Implements design/game-brief.md MVP feature 2 (story-002-dig-action) and the
## reveal step of MVP feature 4 (story-004-treasures-and-trap).

## Cell offsets, relative to the tapped cell, that one dig covers. The default
## is exactly one tile (the tapped cell only). This is the structural default,
## not a tuning knob; story 005 widens the range by assigning a larger array.
var dig_range: Array[Vector2i] = [Vector2i.ZERO]

## Treasure revealed this run and not yet carried home, in dig order. Story 006
## reads it when the player returns to the boat (and clears it on a new run).
var inventory: Array[TileContent] = []

var _tide_timer: TideTimer


## Injects the tide clock a dug trap raises. A system with none injected
## reveals traps without effect.
func set_tide_timer(timer: TideTimer) -> void:
	_tide_timer = timer


## Returns the summed score value of `inventory`.
func get_inventory_value() -> int:
	var total: int = 0
	for content: TileContent in inventory:
		total += content.value
	return total


## Converts `position` (in the same coordinate space as `origin`) to the grid
## cell it falls in, for a grid of `columns` x `rows` square cells of
## `cell_size` whose top-left corner is at `origin`. Returns IslandGrid.NO_CELL
## when the position lies outside the grid.
static func position_to_cell(
		position: Vector2, cell_size: float, origin: Vector2, columns: int, rows: int) -> Vector2i:
	if cell_size <= 0.0:
		return IslandGrid.NO_CELL
	var local: Vector2 = (position - origin) / cell_size
	var cell := Vector2i(floori(local.x), floori(local.y))
	if cell.x < 0 or cell.x >= columns or cell.y < 0 or cell.y >= rows:
		return IslandGrid.NO_CELL
	return cell


## Digs every cell of `dig_range` around `tapped_cell` that is in bounds, LAND
## and not yet dug. SEA cells, out-of-grid cells and already-dug cells are
## skipped silently. Each newly dug cell's contents take effect once: a
## TREASURE is appended to `inventory`, a TRAP adds its tide seconds to the
## injected tide timer, EMPTY or no contents do nothing. Returns the cells newly
## dug (empty when nothing changed).
func dig(grid: IslandGrid, tapped_cell: Vector2i) -> Array[Vector2i]:
	var newly_dug: Array[Vector2i] = []
	for offset: Vector2i in dig_range:
		var cell: Vector2i = tapped_cell + offset
		if not (grid.is_in_bounds(cell) and grid.mark_dug(cell)):
			continue
		newly_dug.append(cell)
		var content: TileContent = grid.get_contents(cell)
		if content == null:
			continue
		match content.kind:
			TileContent.Kind.TREASURE:
				inventory.append(content)
			TileContent.Kind.TRAP:
				if _tide_timer != null:
					_tide_timer.add_tide(content.tide_seconds)
			# TileContent.Kind.TOOL: the shovel upgrade effect is story 005.
	return newly_dug
