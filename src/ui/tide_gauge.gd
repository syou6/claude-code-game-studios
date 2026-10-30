class_name TideGauge
extends Control
## Vertical tide gauge: a bar on the left edge of the screen whose water fill
## rises from the bottom with the tide level. Shows a different fill colour and
## the label "満潮" once the run has failed. Presentation only: it is told the
## level and the failed flag, and holds no game logic. Ignores mouse/touch so
## taps pass through to the island underneath.
## Implements design/game-brief.md MVP feature 3 (story-003-tide-timer).

## Width of the gauge in pixels. The composer (main.gd) sizes the control to
## this; it is a layout constant, not a tuning knob.
const WIDTH: float = 40.0
## Colour of the empty part of the gauge.
const BACKGROUND_COLOR: Color = Color(0.08, 0.10, 0.16)
## Colour of the water fill while the run is still going.
const WATER_COLOR: Color = Color(0.16, 0.42, 0.78)
## Colour of the water fill once the run has failed.
const FLOODED_COLOR: Color = Color(0.85, 0.20, 0.20)
## Colour of the failed label.
const LABEL_COLOR: Color = Color.WHITE
## Text shown (one character per line, top of the gauge) when failed.
const FULL_TIDE_LABEL: String = "満潮"
## Font size of the failed label, in pixels. Must fit inside WIDTH.
const LABEL_FONT_SIZE: int = 28
## Gap between the top of the gauge and the failed label, in pixels.
const LABEL_TOP_MARGIN: float = 16.0

var _level: float = 0.0
var _failed: bool = false


func _ready() -> void:
	# Let taps fall through to the IslandView; the gauge never handles input.
	mouse_filter = MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


## Sets the water level, `level` in [0, 1] (0 = empty, 1 = full), and redraws.
func set_level(level: float) -> void:
	_level = level
	queue_redraw()


## Sets whether the run has failed (flooded colour and label) and redraws.
func set_failed(failed: bool) -> void:
	_failed = failed
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), BACKGROUND_COLOR)
	var water_height: float = size.y * _level
	var water_rect := Rect2(0.0, size.y - water_height, size.x, water_height)
	draw_rect(water_rect, FLOODED_COLOR if _failed else WATER_COLOR)
	if not _failed:
		return
	var font: Font = get_theme_default_font()
	var label: String = tr(FULL_TIDE_LABEL)
	for i: int in label.length():
		var baseline := Vector2(0.0, LABEL_TOP_MARGIN + (i + 1) * LABEL_FONT_SIZE)
		draw_string(font, baseline, label[i], HORIZONTAL_ALIGNMENT_CENTER,
			size.x, LABEL_FONT_SIZE, LABEL_COLOR)
