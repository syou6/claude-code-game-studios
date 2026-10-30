class_name IslandGrid
extends RefCounted
## Data model of one island: a rectangular grid of SEA / LAND tiles, one boat
## cell, a per-land-tile contents slot and a per-tile dug flag. Pure data, no
## scene dependency, so it can be unit-tested without a running game.
## Implements design/game-brief.md MVP feature 1 (story-001-island-generation)
## and the dug state of MVP feature 2 (story-002-dig-action).

## Kind of a tile.
enum TileType { SEA, LAND }

## 4-neighbour offsets (up, down, left, right).
const NEIGHBOR_OFFSETS: Array[Vector2i] = [
	Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0),
]

## Value of `boat_cell` before a generator has placed the boat, and the
## "no cell" result of a position that lies outside the grid.
const NO_CELL: Vector2i = Vector2i(-1, -1)

## Number of columns (width in tiles).
var columns: int
## Number of rows (height in tiles).
var rows: int
## The boat's starting cell: a SEA tile 4-adjacent to at least one LAND tile.
var boat_cell: Vector2i = NO_CELL

var _tiles: Array[int] = []
var _contents: Array = []
var _dug: Array[bool] = []
var _land_count: int = 0


## Creates a grid of the given size with every tile SEA, undug and no contents.
func _init(p_columns: int, p_rows: int) -> void:
	columns = p_columns
	rows = p_rows
	_tiles.resize(columns * rows)
	_tiles.fill(TileType.SEA)
	_contents.resize(columns * rows)
	_dug.resize(columns * rows)
	_dug.fill(false)


## Returns true when `cell` lies inside the grid.
func is_in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < columns and cell.y >= 0 and cell.y < rows


## Returns the tile type at `cell` (must be in bounds).
func get_tile(cell: Vector2i) -> TileType:
	return _tiles[_index_of(cell)] as TileType


## Sets the tile type at `cell`. Turning a tile into SEA clears its contents
## and its dug state.
func set_tile(cell: Vector2i, tile_type: TileType) -> void:
	var index: int = _index_of(cell)
	if _tiles[index] == TileType.LAND:
		_land_count -= 1
	if tile_type == TileType.LAND:
		_land_count += 1
	else:
		_contents[index] = null
		_dug[index] = false
	_tiles[index] = tile_type


## Returns true when the tile at `cell` is LAND.
func is_land(cell: Vector2i) -> bool:
	return get_tile(cell) == TileType.LAND


## Returns the number of LAND tiles in the grid.
func get_land_count() -> int:
	return _land_count


## Returns how many of the 4 neighbours of `cell` are in bounds and LAND.
func count_land_neighbors(cell: Vector2i) -> int:
	var count: int = 0
	for offset: Vector2i in NEIGHBOR_OFFSETS:
		var neighbor: Vector2i = cell + offset
		if is_in_bounds(neighbor) and is_land(neighbor):
			count += 1
	return count


## Returns true when the tile at `cell` (must be in bounds) has been dug.
## A dug tile's contents are revealed: `get_contents(cell)` is now meaningful
## to show. SEA tiles are never dug.
func is_dug(cell: Vector2i) -> bool:
	return _dug[_index_of(cell)]


## Marks the tile at `cell` (must be in bounds) as dug. Returns true when the
## tile changed from undug to dug; returns false, changing nothing, for a SEA
## tile or a tile that is already dug.
func mark_dug(cell: Vector2i) -> bool:
	var index: int = _index_of(cell)
	if _tiles[index] != TileType.LAND or _dug[index]:
		return false
	_dug[index] = true
	return true


## Returns what is stored on the land tile at `cell`; null means empty.
## The content type is decided by a later story (story 004).
func get_contents(cell: Vector2i) -> Variant:
	return _contents[_index_of(cell)]


## Stores `contents` on the land tile at `cell` (null = empty).
func set_contents(cell: Vector2i, contents: Variant) -> void:
	assert(is_land(cell), "Only LAND tiles can hold contents.")
	_contents[_index_of(cell)] = contents


func _index_of(cell: Vector2i) -> int:
	return cell.y * columns + cell.x
