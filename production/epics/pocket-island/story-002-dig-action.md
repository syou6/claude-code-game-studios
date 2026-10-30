# Story 002: タイルを掘って中身を判明させる

> **Epic**: pocket-island
> **Status**: In Progress
> **Layer**: N/A (minimal — no layers)
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-30

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief MVP feature 2 — 掘るアクション(1タイルを掘ると中身が判明する)

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

- [ ] 未掘削の陸タイルをタップすると、そのタイルが「掘削済み」になり、中身が判明する
- [ ] 掘削済みのタイルをもう一度タップしても何も起きない(再掘削されない)
- [ ] 海タイルと島の外のタップは無視される
- [ ] 一度に掘る範囲は「掘削範囲」の値で決まり、既定は1タイルである(広げるのはストーリー005)
- [ ] タップした画面座標が、画面サイズが変わっても同じ格子座標のタイルに対応する
- [ ] タップと同じフレームで状態が更新され、タイルの見た目が掘削済みに変わる
- [ ] 掘削の判定ロジックは画面表示から分離され、入力なしで単体テストできる

---

## Implementation Notes

- タッチ入力を扱う前に `docs/engine-reference/godot/modules/input.md` を読む(4.7 ではマウス/タッチのフォーカスがキーボード/ゲームパッドと分離されている)。
- 画面座標から格子座標への変換は、純粋関数として切り出してテストできるようにする。
- 掘削済みの状態は島のデータモデル(ストーリー001)に持たせ、表示側は状態を読むだけにする。
- 効果音は今回の範囲外。視覚的な反応だけを実装する。

---

## Out of Scope

*Handled by neighbouring stories — do not implement here:*

- Story 004: 中身の種類(宝・罠・空)の判定と効果
- Story 005: 掘削範囲の拡大
- 効果音と演出の磨き込み(MVP 外)

---

## Files

- `src/island/dig_system.gd` — created (position-to-cell conversion, dig logic, dig range)
- `src/island/island_grid.gd` — modified (per-tile dug state)
- `src/island/island_view.gd` — modified (tap input, shared layout, dug colour)
- No test file: waived at `qa.level: minimal`

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*Governed by `qa.level`: at `qa.level: minimal` tests are **waived** (advisory), but a retained screenshot of anything the player sees is not.*

**Story Type**: Logic
**Required evidence**:
- `tests/unit/island/dig_system_test.gd` — advisory at `qa.level: minimal`
- 掘削前後の画面のスクリーンショット: `production/qa/evidence/story-002-dig-action.png`

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/pocket-island/story-001-island-generation.md`
- Unlocks: `production/epics/pocket-island/story-003-tide-timer.md`, `production/epics/pocket-island/story-004-treasures-and-trap.md`
