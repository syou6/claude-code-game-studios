# island_config.json — schema

Read by `src/main.gd` and passed to `IslandGenerator.generate()`. Every key is
required and numeric. Values are tuning knobs for story 001; none are playtested.

| Key | Type | Meaning |
|---|---|---|
| `columns` | whole number | Grid width in tiles. |
| `rows` | whole number | Grid height in tiles. Taller than wide suits portrait phones. |
| `edge_margin` | whole number, >= 1 | Ring of tiles around the grid that always stays sea. Must be at least 1 so the boat has open sea to start from, and `columns` and `rows` must each exceed `2 * edge_margin`. |
| `land_fill_ratio` | 0 < x <= 1 | Fraction of the inner area (inside the margin) that becomes land. 0.6 of a 7x9 interior is about 38 land tiles. |
| `compactness` | >= 0 | How strongly growth prefers tiles already surrounded by land: weight = 1 + compactness * (land neighbours - 1). 0 allows long tendrils; higher values make rounder islands. |
