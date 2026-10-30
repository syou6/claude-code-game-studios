class_name IslandView
extends Control
## Draws an IslandGrid as colored rectangles, scaled to fit and centered in
## this control, and turns taps into dig requests. Recomputes the layout
## whenever the control is resized; drawing and input share one layout helper
## so a tap always maps to the tile drawn under it.
## Implements design/game-brief.md MVP features 1 and 2
## (story-001-island-generation, story-002-dig-action); the dig gate on the
## run's phase is MVP feature 3 (story-003-tide-timer).

## Color of SEA tiles.
const SEA_COLOR: Color = Color(0.16, 0.42, 0.78)
## Color of LAND tiles that have not been dug.
const LAND_UNDUG_COLOR: Color = Color(0.86, 0.78, 0.45)
## Color of LAND tiles that have been dug (clearly darker than undug land).
const LAND_DUG_COLOR: Color = Color(0.42, 0.26, 0.14)
## Color of the boat's tile.
const BOAT_COLOR: Color = Color(0.93, 0.35, 0.15)
## Fraction of a cell left empty on each side, to show the grid.
const TILE_INSET_RATIO: float = 0.04

var _grid: IslandGrid
var _dig_system: DigSystem
var _run_state: RunState
var _cell_size: float = 0.0
var _origin: Vector2 = Vector2.ZERO


func _ready() -> void:
	resized.connect(queue_redraw)
	# Default composition: if no DigSystem was injected before the view entered
	# the tree, create one here so main.gd needs no change. Inject one with
	# set_dig_system() to share or configure it (e.g. a wider range, story 005).
	if _dig_system == null:
		_dig_system = DigSystem.new()


## Sets the grid to display and redraws.
func set_grid(grid: IslandGrid) -> void:
	_grid = grid
	queue_redraw()


## Injects the DigSystem used to handle taps. Call before or after the view
## enters the tree; a view with none injected creates a default one in _ready().
func set_dig_system(dig_system: DigSystem) -> void:
	_dig_system = dig_system


## Injects the run state that gates digging: taps are refused unless
## `run_state.can_dig()` is true (a failed or finished run). A view with none
## injected always digs.
func set_run_state(run_state: RunState) -> void:
	_run_state = run_state


## Handles a left mouse press or a screen touch press as a dig tap. Godot's
## default touch-to-mouse emulation delivers phone taps as mouse events; a
## ScreenTouch for the same tap is harmless because re-digging is a no-op.
func _gui_input(event: InputEvent) -> void:
	var tap_position: Vector2
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		if not mouse_event.pressed or mouse_event.button_index != MOUSE_BUTTON_LEFT:
			return
		tap_position = mouse_event.position
	elif event is InputEventScreenTouch:
		var touch_event: InputEventScreenTouch = event
		if not touch_event.pressed:
			return
		tap_position = touch_event.position
	else:
		return
	_handle_tap(tap_position)
	accept_event()


func _draw() -> void:
	if _grid == null:
		return
	_update_layout()
	var inset: float = _cell_size * TILE_INSET_RATIO
	for y: int in _grid.rows:
		for x: int in _grid.columns:
			var cell := Vector2i(x, y)
			var color: Color = SEA_COLOR
			if _grid.is_land(cell):
				color = LAND_DUG_COLOR if _grid.is_dug(cell) else LAND_UNDUG_COLOR
			elif cell == _grid.boat_cell:
				color = BOAT_COLOR
			var rect := Rect2(_origin + Vector2(x, y) * _cell_size, Vector2(_cell_size, _cell_size))
			draw_rect(rect.grow(-inset), color)


# Single source of the cell size and grid origin, used by both _draw and input.
func _update_layout() -> void:
	_cell_size = minf(size.x / _grid.columns, size.y / _grid.rows)
	_origin = (size - Vector2(_grid.columns, _grid.rows) * _cell_size) / 2.0


# `local_position` is in this control's coordinate space (as given to _gui_input).
func _handle_tap(local_position: Vector2) -> void:
	if _grid == null or _dig_system == null:
		return
	if _run_state != null and not _run_state.can_dig():
		return
	_update_layout()
	var cell: Vector2i = DigSystem.position_to_cell(
		local_position, _cell_size, _origin, _grid.columns, _grid.rows)
	if cell == IslandGrid.NO_CELL:
		return
	if not _dig_system.dig(_grid, cell).is_empty():
		queue_redraw()
