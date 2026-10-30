# Story 003: 潮位タイマーと満潮時の失敗判定

> **Epic**: pocket-island
> **Status**: Ready
> **Layer**: N/A (minimal — no layers)
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: [set by /dev-story when implementation begins]

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief MVP feature 3 — 潮位タイマーと、満潮時の失敗判定

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**:
N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Player goal & fail state), scoped to this story:*

- [ ] 潮位ゲージは0から始まり、時間とともに一定の割合で上がる
- [ ] ゲージが満ちるまでの時間は外部データファイルの値で決まり、既定の目安は約5分(ブリーフのピッチによる)
- [ ] ゲージが満ちた時点で、舟に戻っていなければ「失敗」状態になる
- [ ] 「舟に戻った」状態は、ストーリー006の帰還で成立するフラグとして参照する
- [ ] 失敗状態では掘削入力が受け付けられなくなる
- [ ] 失敗した回に集めた宝は、持ち帰りスコアに加算されない
- [ ] 潮位ゲージが画面に表示され、現在の水位が分かる
- [ ] アプリが背景に回っても状態が壊れず、復帰後に再開できる

---

## Implementation Notes

- タイマーは経過時間を状態として持ち、画面更新とは分離する。進行の計算は単体テストで時間を直接与えて確かめられるようにする(実時間に依存しない)。
- ゲージの上昇量を外から加える入口を用意する(ストーリー004の罠が使う)。
- 背景化時の扱いは Godot の通知(アプリの一時停止・再開)を使う。実装前に `docs/engine-reference/godot/` で該当APIを確かめる。

---

## Out of Scope

*Handled by neighbouring stories — do not implement here:*

- Story 004: 罠による潮位の上昇
- Story 006: 舟へ戻る操作と成功判定、スコア表示
- Story 007: リスタート

---

## Files

- `src/tide/tide_timer.gd`
- `src/tide/run_state.gd`
- `src/ui/tide_gauge.gd`
- `assets/data/tide_config.json`
- `tests/unit/tide/tide_timer_test.gd`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*Governed by `qa.level`: at `qa.level: minimal` tests are **waived** (advisory), but a retained screenshot of anything the player sees is not.*

**Story Type**: Logic
**Required evidence**:
- `tests/unit/tide/tide_timer_test.gd` — advisory at `qa.level: minimal`
- ゲージが途中の画面と、満潮で失敗した画面のスクリーンショット: `production/qa/evidence/story-003-tide-timer.png`

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/pocket-island/story-002-dig-action.md`
- Unlocks: `production/epics/pocket-island/story-006-boat-return-and-score.md`
