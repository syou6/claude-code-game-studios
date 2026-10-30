class_name IslandView
extends Control
## Draws an IslandGrid as colored rectangles, scaled to fit and centered in
## this control. Recomputes the layout whenever the control is resized.
## Implements design/game-brief.md MVP feature 1 (story-001-island-generation).

## Color of SEA tiles.
const SEA_COLOR: Color = Color(0.16, 0.42, 0.78)
## Color of LAND tiles that have not been dug.
const LAND_UNDUG_COLOR: Color = Color(0.86, 0.78, 0.45)
## Color of the boat's tile.
const BOAT_COLOR: Color = Color(0.93, 0.35, 0.15)
## Fraction of a cell left empty on each side, to show the grid.
const TILE_INSET_RATIO: float = 0.04

var _grid: IslandGrid


func _ready() -> void:
	resized.connect(queue_redraw)


## Sets the grid to display and redraws.
func set_grid(grid: IslandGrid) -> void:
	_grid = grid
	queue_redraw()


func _draw() -> void:
	if _grid == null:
		return
	var cell_size: float = minf(size.x / _grid.columns, size.y / _grid.rows)
	var origin: Vector2 = (size - Vector2(_grid.columns, _grid.rows) * cell_size) / 2.0
	var inset: float = cell_size * TILE_INSET_RATIO
	for y: int in _grid.rows:
		for x: int in _grid.columns:
			var cell := Vector2i(x, y)
			var color: Color = SEA_COLOR
			if _grid.is_land(cell):
				color = LAND_UNDUG_COLOR
			elif cell == _grid.boat_cell:
				color = BOAT_COLOR
			var rect := Rect2(origin + Vector2(x, y) * cell_size, Vector2(cell_size, cell_size))
			draw_rect(rect.grow(-inset), color)
