class_name IslandGenerator
extends RefCounted
## Generates an IslandGrid from a seed and a config. Stateless and free of
## scene/global dependencies; the same (seed, config, table) always gives the
## same island, contents included.
## Implements design/game-brief.md MVP feature 1 (story-001-island-generation);
## the contents step is MVP feature 4 (story-004-treasures-and-trap).
##
## Connectivity is guaranteed by construction: land starts as one tile and only
## ever grows by converting a SEA tile that is 4-adjacent to existing land.


## Builds an island.
## `config` must already be validated (see main.gd) and holds:
##   columns, rows        - grid size in tiles
##   edge_margin          - border ring of tiles that always stay SEA
##   land_fill_ratio      - fraction of the non-margin area that becomes LAND
##   compactness          - 0 = tendrils allowed, higher = rounder blobs
## `table`, when given, fills every LAND tile with contents after the boat is
## placed, drawing from the same rng so one seed reproduces land and contents.
## With no table the land tiles are left without contents (null).
static func generate(seed_value: int, config: Dictionary, table: TreasureTable = null) -> IslandGrid:
	var columns: int = int(config["columns"])
	var rows: int = int(config["rows"])
	var margin: int = int(config["edge_margin"])
	var fill_ratio: float = float(config["land_fill_ratio"])
	var compactness: float = float(config["compactness"])

	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value

	var grid := IslandGrid.new(columns, rows)
	var interior_area: int = (columns - 2 * margin) * (rows - 2 * margin)
	var target_land: int = maxi(1, roundi(fill_ratio * interior_area))

	var start := Vector2i(
		rng.randi_range(margin, columns - margin - 1),
		rng.randi_range(margin, rows - margin - 1))
	grid.set_tile(start, IslandGrid.TileType.LAND)

	while grid.get_land_count() < target_land:
		var candidates: Array[Vector2i] = []
		var weights: Array[float] = []
		var total_weight: float = 0.0
		for y: int in range(margin, rows - margin):
			for x: int in range(margin, columns - margin):
				var cell := Vector2i(x, y)
				if grid.is_land(cell):
					continue
				var land_neighbors: int = grid.count_land_neighbors(cell)
				if land_neighbors == 0:
					continue
				var weight: float = 1.0 + compactness * (land_neighbors - 1)
				candidates.append(cell)
				weights.append(weight)
				total_weight += weight

		var pick: float = rng.randf() * total_weight
		var chosen: Vector2i = candidates[candidates.size() - 1]
		for i: int in candidates.size():
			if pick < weights[i]:
				chosen = candidates[i]
				break
			pick -= weights[i]
		grid.set_tile(chosen, IslandGrid.TileType.LAND)

	var boat_candidates: Array[Vector2i] = _find_open_sea_shore(grid)
	grid.boat_cell = boat_candidates[rng.randi_range(0, boat_candidates.size() - 1)]

	if table != null:
		table.populate(grid, rng)

	return grid


## Returns every SEA tile that touches LAND and is reachable from the open sea
## (the sea around the island), in row-major order. Sea enclosed by land is
## excluded, so the boat never starts in a lake. The edge margin guarantees the
## corner tile is sea and the outer ring is connected, so the fill starts there.
static func _find_open_sea_shore(grid: IslandGrid) -> Array[Vector2i]:
	var visited: Array[bool] = []
	visited.resize(grid.columns * grid.rows)
	visited.fill(false)
	var frontier: Array[Vector2i] = [Vector2i.ZERO]
	visited[0] = true
	var shore: Array[Vector2i] = []
	while not frontier.is_empty():
		var cell: Vector2i = frontier.pop_back()
		if grid.count_land_neighbors(cell) > 0:
			shore.append(cell)
		for offset: Vector2i in IslandGrid.NEIGHBOR_OFFSETS:
			var neighbor: Vector2i = cell + offset
			if not grid.is_in_bounds(neighbor) or grid.is_land(neighbor):
				continue
			var index: int = neighbor.y * grid.columns + neighbor.x
			if visited[index]:
				continue
			visited[index] = true
			frontier.append(neighbor)
	shore.sort()
	return shore
