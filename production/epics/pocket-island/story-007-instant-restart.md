# Story 007: 即時リスタート(次の島へ)

> **Epic**: pocket-island
> **Status**: Ready
> **Layer**: N/A (minimal — no layers)
> **Type**: Logic
> **Estimate**: S
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: [set by /dev-story when implementation begins]

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief MVP feature 7 — リスタート(即座に次の島へ)

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

- [ ] 結果画面から、1回の操作でリスタートできる
- [ ] 成功後も失敗後も、リスタートできる
- [ ] リスタートすると、新しいシードで新しい島が生成される
- [ ] 潮位ゲージ、所持品、掘削範囲、掘削済みの状態が初期値に戻る
- [ ] 合計スコアは、リスタートをまたいで保持される(起動中のみ)
- [ ] 読み込み画面を挟まず、すぐ新しい島が表示される
- [ ] 続けて何度リスタートしても、タイマーやノードが重複して増えない

---

## Implementation Notes

- リセットは「ラン状態を作り直す」1か所にまとめる。各システムが個別に値を戻す形にしない。
- 前の島のノードを確実に解放してから新しい島を作る(重複したタイマーや入力を残さない)。
- 新しいシードの決め方(時刻など)は、テストでは固定値を差し込めるようにする。

---

## Out of Scope

*Handled by neighbouring stories — do not implement here:*

- Story 006: 結果画面の表示内容
- タイトル画面、メニュー(MVP 外)

---

## Files

- `src/run/run_controller.gd`
- `src/ui/result_screen.tscn`(リスタート操作を追加)
- `tests/unit/run/restart_test.gd`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*Governed by `qa.level`: at `qa.level: minimal` tests are **waived** (advisory), but a retained screenshot of anything the player sees is not.*

**Story Type**: Logic
**Required evidence**:
- `tests/unit/run/restart_test.gd` — advisory at `qa.level: minimal`
- リスタート直後の新しい島のスクリーンショット: `production/qa/evidence/story-007-instant-restart.png`

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/pocket-island/story-006-boat-return-and-score.md`
- Unlocks: None
