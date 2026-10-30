# Story 004: 宝3種と罠1種

> **Epic**: pocket-island
> **Status**: In Progress
> **Layer**: N/A (minimal — no layers)
> **Type**: Logic
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-30

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief MVP feature 4 — 3種類の宝(価値が異なる)と、1種類の罠(時間を奪う)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**:
N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md`, scoped to this story:*

- [ ] 宝は3種類で、それぞれ価値(スコア)が異なり、価値は外部データファイルから読む
- [ ] 罠は1種類で、掘ると潮位ゲージが所定量だけ上がる。上昇量はデータファイルの値である
- [ ] 各陸タイルの中身は「宝(3種)・罠・道具・空」のいずれかで、出現の比率はデータファイルで決まる
- [ ] 同じシードなら宝と罠の配置が再現される
- [ ] 掘って判明した宝は「所持品(未回収)」に加わる
- [ ] 宝・罠・空は画面上で種類ごとに見分けられる
- [ ] 罠でゲージが上限を超える場合は上限で止まり、満潮の失敗判定(ストーリー003)が同じ規則で働く

---

## Implementation Notes

- 中身の種類と価値、罠の上昇量、出現比率はすべて `assets/data/` のデータに置く(コードに直書きしない)。
- 中身の決定は島生成(ストーリー001)の結果に対して行い、乱数のシードを共有して再現できるようにする。
- 「道具」の種類はストーリー005が定義する。ここでは「道具が入る枠」を用意するだけにする。

---

## Out of Scope

*Handled by neighbouring stories — do not implement here:*

- Story 005: シャベル強化の効果
- Story 006: 所持品の回収とスコア加算

---

## Files

- `src/items/tile_content.gd` — created (content kinds: empty, treasure, trap, tool)
- `src/items/treasure_table.gd` — created (weighted pick, populate every land tile)
- `src/island/dig_system.gd` — modified (inventory, trap applies tide via injected timer)
- `src/island/island_generator.gd` — modified (optional table, same rng)
- `src/island/island_view.gd` — modified (per-kind colour on dug tiles)
- `src/main.gd` — modified (items config validation, table and dig system wiring)
- `assets/data/items.json` — created (weights, 3 treasures, trap, tool slot)
- `assets/data/items.md` — created (schema)
- No test file: waived at `qa.level: minimal`

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*Governed by `qa.level`: at `qa.level: minimal` tests are **waived** (advisory), but a retained screenshot of anything the player sees is not.*

**Story Type**: Logic
**Required evidence**:
- `tests/unit/items/treasure_table_test.gd` — advisory at `qa.level: minimal`
- 宝・罠・空を掘り当てた画面のスクリーンショット: `production/qa/evidence/story-004-treasures-and-trap.png`

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/pocket-island/story-002-dig-action.md`, `production/epics/pocket-island/story-003-tide-timer.md`
- Unlocks: `production/epics/pocket-island/story-005-shovel-upgrade.md`, `production/epics/pocket-island/story-006-boat-return-and-score.md`
