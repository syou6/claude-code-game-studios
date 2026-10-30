class_name TideTimer
extends RefCounted
## Pure tide clock: accumulates play time (and tide added from outside, e.g. a
## trap) and reports how full the tide gauge is. Time is only what callers pass
## in — no Timer node, no Time.* or real-clock reads — so the progression is
## deterministic and can be unit-tested by feeding seconds directly.
## Implements design/game-brief.md MVP feature 3 (story-003-tide-timer).

## Seconds of tide time at which the gauge is full. From tide_config.json.
var full_tide_seconds: float

var _tide_seconds: float = 0.0


## Creates a timer at low tide (level 0) that is full after
## `p_full_tide_seconds` seconds of tide time. Must be > 0 (validated by the
## config loader).
func _init(p_full_tide_seconds: float) -> void:
	full_tide_seconds = p_full_tide_seconds


## Advances the tide by `delta` seconds of play time, never past full.
func advance(delta: float) -> void:
	_tide_seconds = minf(_tide_seconds + delta, full_tide_seconds)


## Adds `seconds` of tide on top of play time, never past full. This is the
## entry point story 004's trap uses to raise the tide.
func add_tide(seconds: float) -> void:
	_tide_seconds = minf(_tide_seconds + seconds, full_tide_seconds)


## Returns how full the gauge is, in [0, 1]: 0 at the start, 1 at full tide.
func get_level() -> float:
	return _tide_seconds / full_tide_seconds


## Returns true once the tide has reached full.
func is_full() -> bool:
	return _tide_seconds >= full_tide_seconds
