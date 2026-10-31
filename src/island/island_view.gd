class_name IslandView
extends Control
## Draws an IslandGrid as colored rectangles, scaled to fit and centered in
## this control, and turns taps into dig requests. Recomputes the layout
## whenever the control is resized; drawing and input share one layout helper
## so a tap always maps to the tile drawn under it.
## Implements design/game-brief.md MVP features 1 and 2
## (story-001-island-generation, story-002-dig-action); the dig gate on the
## run's phase is MVP feature 3 (story-003-tide-timer); the per-kind look of a
## dug tile's contents is MVP feature 4 (story-004-treasures-and-trap); the
## acquired-upgrade frame is MVP feature 5 (story-005-shovel-upgrade).

## Color of SEA tiles.
const SEA_COLOR: Color = Color(0.16, 0.42, 0.78)
## Color of LAND tiles that have not been dug.
const LAND_UNDUG_COLOR: Color = Color(0.86, 0.78, 0.45)
## Color of LAND tiles that have been dug (clearly darker than undug land). A
## dug tile with EMPTY or no contents shows only this color.
const LAND_DUG_COLOR: Color = Color(0.42, 0.26, 0.14)
## Color of the boat's tile.
const BOAT_COLOR: Color = Color(0.93, 0.35, 0.15)
## Color of a revealed TREASURE (gold), drawn as an inner square on dug land.
const TREASURE_COLOR: Color = Color(1.0, 0.84, 0.2)
## Color of a revealed TRAP (purple; distinct from the orange boat and from the
## red failed-tide gauge).
const TRAP_COLOR: Color = Color(0.6, 0.15, 0.7)
## Color of a revealed TOOL slot (teal), and of the frame drawn around the grid
## once the shovel upgrade is acquired, so the two read as one thing.
const TOOL_COLOR: Color = Color(0.1, 0.78, 0.72)
## Line width, in pixels, of the shovel-upgrade frame. Godot 4.7 draws
## CanvasItem lines with no antialiasing feather, so the width alone must make
## the frame read clearly; 4 px does on a phone screen. Presentation constant.
const UPGRADE_FRAME_WIDTH: float = 4.0
## Gap, in pixels, between the grid's outer edge and the upgrade frame, so the
## frame never touches a tile. Presentation constant.
const UPGRADE_FRAME_GAP: float = 2.0
## Fraction of a cell left empty on each side, to show the grid.
const TILE_INSET_RATIO: float = 0.04
## Fraction of a cell left as dug-brown border on each side of the contents
## square, so a tile reads as both "dug" and "holds this kind".
const CONTENT_INSET_RATIO: float = 0.22

var _grid: IslandGrid
var _dig_system: DigSystem
var _run_state: RunState
var _cell_size: float = 0.0
var _origin: Vector2 = Vector2.ZERO
# True when Godot also turns every touch into a mouse press, so a ScreenTouch
# must be ignored to handle each tap once (see _gui_input).
var _touch_arrives_as_mouse: bool = true


func _ready() -> void:
	resized.connect(queue_redraw)
	_touch_arrives_as_mouse = ProjectSettings.get_setting(
		"input_devices/pointing/emulate_mouse_from_touch", true)
	# Fallback composition: a view that never gets set_dig_system() still digs.
	# This runs before the parent's _ready (children are readied first), so an
	# injection made there replaces this default; an injected system always wins.
	if _dig_system == null:
		_dig_system = DigSystem.new()


## Sets the grid to display and redraws.
func set_grid(grid: IslandGrid) -> void:
	_grid = grid
	queue_redraw()


## Injects the DigSystem used to handle taps. Call before or after the view
## enters the tree; the injected system replaces the default one _ready() makes
## for a view that had none, so the caller's system is always the one used.
func set_dig_system(dig_system: DigSystem) -> void:
	_dig_system = dig_system


## Injects the run state that gates digging: taps are refused unless
## `run_state.can_dig()` is true (a failed or finished run). A view with none
## injected always digs.
func set_run_state(run_state: RunState) -> void:
	_run_state = run_state


## Handles a left mouse press or a screen touch press as a dig tap, exactly once
## per tap. With touch-to-mouse emulation on (the project default, read in
## _ready), one phone tap arrives as BOTH a ScreenTouch and a mouse press
## (observed on 4.7.2); only the mouse press is used then. Handling both would
## dig twice, and after the shovel upgrade the second dig would already use the
## wider range on the very tap that found the tool (story 005).
func _gui_input(event: InputEvent) -> void:
	var tap_position: Vector2
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		if not mouse_event.pressed or mouse_event.button_index != MOUSE_BUTTON_LEFT:
			return
		tap_position = mouse_event.position
	elif event is InputEventScreenTouch:
		var touch_event: InputEventScreenTouch = event
		if not touch_event.pressed or _touch_arrives_as_mouse:
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
	var content_inset: float = _cell_size * CONTENT_INSET_RATIO
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
			if not (_grid.is_land(cell) and _grid.is_dug(cell)):
				continue
			# Revealed contents: an inner square in the kind's color over the
			# dug-brown. EMPTY and unpopulated (null) tiles stay plain dug-brown.
			var content: TileContent = _grid.get_contents(cell)
			if content == null:
				continue
			match content.kind:
				TileContent.Kind.TREASURE:
					draw_rect(rect.grow(-content_inset), TREASURE_COLOR)
				TileContent.Kind.TRAP:
					draw_rect(rect.grow(-content_inset), TRAP_COLOR)
				TileContent.Kind.TOOL:
					draw_rect(rect.grow(-content_inset), TOOL_COLOR)
	if _dig_system != null and _dig_system.has_upgrade():
		# Assumes the outline stroke is centred on the rect's edge (not covered
		# by docs/engine-reference/godot/); this rect then puts the whole stroke
		# in the margin _update_layout reserves outside the tiles.
		var grid_rect := Rect2(_origin, Vector2(_grid.columns, _grid.rows) * _cell_size)
		draw_rect(
			grid_rect.grow(UPGRADE_FRAME_GAP + UPGRADE_FRAME_WIDTH / 2.0),
			TOOL_COLOR, false, UPGRADE_FRAME_WIDTH)


# Single source of the cell size and grid origin, used by both _draw and input.
# A margin for the upgrade frame is kept on every side even before the upgrade,
# so the frame never covers a tile or leaves the control and the tiles never
# move when the upgrade is acquired.
func _update_layout() -> void:
	var frame_margin: float = UPGRADE_FRAME_GAP + UPGRADE_FRAME_WIDTH
	var available: Vector2 = size - Vector2(frame_margin, frame_margin) * 2.0
	_cell_size = maxf(0.0, minf(available.x / _grid.columns, available.y / _grid.rows))
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
