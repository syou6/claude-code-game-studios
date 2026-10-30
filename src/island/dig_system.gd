class_name DigSystem
extends RefCounted
## Pure dig logic: converts a position to a grid cell and digs the tiles in the
## dig range around a tapped cell. No scene, node or singleton dependency, so it
## can be unit-tested without a running game.
## Implements design/game-brief.md MVP feature 2 (story-002-dig-action).

## Cell offsets, relative to the tapped cell, that one dig covers. The default
## is exactly one tile (the tapped cell only). This is the structural default,
## not a tuning knob; story 005 widens the range by assigning a larger array.
var dig_range: Array[Vector2i] = [Vector2i.ZERO]


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
## skipped silently. Returns the cells newly dug (empty when nothing changed).
func dig(grid: IslandGrid, tapped_cell: Vector2i) -> Array[Vector2i]:
	var newly_dug: Array[Vector2i] = []
	for offset: Vector2i in dig_range:
		var cell: Vector2i = tapped_cell + offset
		if grid.is_in_bounds(cell) and grid.mark_dug(cell):
			newly_dug.append(cell)
	return newly_dug
