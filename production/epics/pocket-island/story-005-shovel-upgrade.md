# Story 005: シャベル強化(掘れる範囲の拡大)

> **Epic**: pocket-island
> **Status**: Ready
> **Layer**: N/A (minimal — no layers)
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: [set by /dev-story when implementation begins]

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief MVP feature 5 — 1種類の道具(掘れる範囲が広がるシャベル強化)

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

- [ ] 道具は1種類(シャベル強化)で、掘り当てると取得し、以降の掘削範囲が広がる
- [ ] 広がった範囲の形と大きさは外部データファイルの値で決まる
- [ ] 範囲内の複数タイルを一度に掘ると、各タイルの中身が判明し、罠が含まれていれば罠の効果も適用される
- [ ] 範囲が島の端や海にかかっても、範囲外のタイルは無視され、エラーにならない
- [ ] 強化の効果はその島の間だけ有効で、次の島では初期値に戻る(永続強化は作らない — ブリーフの Out of scope)
- [ ] 強化を取得したことが画面で分かる

---

## Implementation Notes

- 掘削範囲は、ストーリー002の「掘削範囲」の値を差し替える形で実装する。掘削ロジックを複製しない。
- 範囲の定義(相対座標の一覧)をデータに置くと、後から形を変えやすい。
- 強化の状態は1回の島のデータ(ラン状態)に持たせ、リスタートで消えるようにする。

---

## Out of Scope

*Handled by neighbouring stories — do not implement here:*

- Story 004: 道具が入る枠と、宝・罠の種類
- Story 007: リスタート時のリセット処理そのもの
- 掘る速さの強化、複数の道具(MVP 外)

---

## Files

- `src/items/shovel_upgrade.gd`
- `src/island/dig_system.gd`(範囲の差し替えに対応)
- `assets/data/items.json`(強化の定義を追加)
- `tests/unit/items/shovel_upgrade_test.gd`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*Governed by `qa.level`: at `qa.level: minimal` tests are **waived** (advisory), but a retained screenshot of anything the player sees is not.*

**Story Type**: Logic
**Required evidence**:
- `tests/unit/items/shovel_upgrade_test.gd` — advisory at `qa.level: minimal`
- 強化前と強化後の掘削範囲が分かるスクリーンショット: `production/qa/evidence/story-005-shovel-upgrade.png`

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/pocket-island/story-004-treasures-and-trap.md`
- Unlocks: None
