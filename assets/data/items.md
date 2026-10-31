# items.json — schema

Read by `src/main.gd`, validated there, and passed to `TreasureTable.new()`,
which fills every land tile of a generated island with one of: empty, a
treasure, the trap or a tool slot. Every key is required. Values are tuning
knobs for story 004; none are playtested. Expected counts below assume the
island_config.json defaults (about 38 land tiles) and a 300-second tide.

| Key | Type | Meaning |
|---|---|---|
| `spawn_weights` | object | Relative chance of each kind of tile contents. Keys must be exactly `empty`, `treasure`, `trap`, `tool`; each value is a number >= 0 and at least one must be > 0. Only ratios matter. |
| `spawn_weights.empty` | number, >= 0 | 50: half the island is empty, so most digs are misses and finding anything feels earned. About 19 empty tiles. |
| `spawn_weights.treasure` | number, >= 0 | 30: about 11 treasures per island — enough that a 5-minute run always has something to carry home. |
| `spawn_weights.trap` | number, >= 0 | 12: about 4-5 traps per island. Hitting every one costs 90-100 seconds, a third of the run, so a careless player still fails but a normal run survives one or two. |
| `spawn_weights.tool` | number, >= 0 | 8: about 3 tool slots per island, so the shovel upgrade (story 005) shows up most runs without being free. |
| `treasures` | array of exactly 3 objects | The three treasure kinds (brief: 3種類の宝). Each has `id`, `value`, `weight`; all three `value`s must differ. |
| `treasures[].id` | non-empty string | Data id of the treasure; shown nowhere yet, used by later stories (score breakdown) and tests. |
| `treasures[].value` | whole number, > 0 | Score when carried back to the boat (story 006). shell 10 / coin 30 / gem 100: a 1 : 3 : 10 ladder so one gem clearly outweighs a pocket of shells. |
| `treasures[].weight` | number, >= 0 | Relative chance among treasures; at least one must be > 0. 60 / 30 / 10 gives roughly 7 shells, 3 coins and 1 gem per island (about 270 points total on the island). |
| `trap` | object | The single trap kind (brief: 1種類の罠). |
| `trap.id` | non-empty string | Data id of the trap. |
| `trap.tide_seconds` | number, > 0 | Tide time added when the trap is dug, on top of elapsed time. 20 is 1/15 of the 300-second run — one trap is a sting, three in a row is a real threat. `TideTimer.add_tide()` clamps at full tide. |
| `tool` | object | The tool slot (placed by story 004). Digging it up grants the shovel upgrade (story 005): every later dig on the same island covers `tool.dig_range`. A second tool on the same island does nothing more. The upgrade ends with the island — the next run starts again with a one-tile dig. |
| `tool.id` | non-empty string | Data id of the tool. `shovel_upgrade` is the brief's one tool (掘れる範囲が広がるシャベル強化). |
| `tool.dig_range` | array of `[x, y]` pairs, at least 1 | The upgraded dig shape: cell offsets relative to the tapped cell (`x` right, `y` down). Each entry is a pair of whole numbers; no pair may repeat; `[0, 0]` (the tapped cell) is required. `main.gd` rejects the file otherwise. Offsets that land outside the grid or on sea are skipped silently. Default is a plus of 5 cells — `[0,0]`, `[1,0]`, `[-1,0]`, `[0,1]`, `[0,-1]` — so one tap digs up to 5x the land of an un-upgraded tap: a clear speed-up against the tide that still leaves aiming to the player, and that also exposes up to 4 unseen tiles at once (any traps among them all apply). Shape and size are both changed by editing this list alone. |
