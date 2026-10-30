# tide_config.json — schema

Read by `src/main.gd` and passed to `TideTimer.new()`. Every key is required and
numeric. Values are tuning knobs for story 003; none are playtested.

| Key | Type | Meaning |
|---|---|---|
| `full_tide_seconds` | number, > 0 | Seconds of play from the start of a run until the tide gauge is full. 300 is the brief's "5分で一周" pitch. A trap (story 004) can add tide time on top of elapsed time, so a run can end sooner, never later. |

Debug/testing only: running the game with a user argument
`--tide-seconds=<float>` after `--` (for example `godot --path . -- --tide-seconds=10`)
overrides this value for that run, so a full tide can be observed in seconds.
An unparsable or non-positive value is ignored with a warning.
