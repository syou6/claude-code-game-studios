class_name TileContent
extends RefCounted
## What one LAND tile hides: a treasure, a trap, a tool slot or nothing. Pure
## data stored in IslandGrid's contents slot by TreasureTable and read by
## DigSystem when the tile is dug. Every number comes from items.json.
## Implements design/game-brief.md MVP feature 4 (story-004-treasures-and-trap);
## the TOOL kind is only a slot here, story 005 gives it an effect.

## Kinds of contents. EMPTY is stored explicitly on populated tiles so a dug
## empty tile and an unpopulated tile (null) both read as "nothing".
enum Kind { EMPTY, TREASURE, TRAP, TOOL }

## Which kind of contents this is.
var kind: Kind
## Data id from items.json (e.g. "shell", "crab"); "" for EMPTY.
var id: String
## Score value of a TREASURE; 0 for every other kind.
var value: int
## Seconds a TRAP adds to the tide when dug; 0 for every other kind.
var tide_seconds: float


## Creates one tile's contents. Only the fields that matter for `p_kind` need
## to be passed; the rest keep their "nothing" defaults.
func _init(p_kind: Kind, p_id: String = "", p_value: int = 0, p_tide_seconds: float = 0.0) -> void:
	kind = p_kind
	id = p_id
	value = p_value
	tide_seconds = p_tide_seconds
