# Story 006: 舟への帰還による回収とスコア表示

> **Epic**: pocket-island
> **Status**: Ready
> **Layer**: N/A (minimal — no layers)
> **Type**: Integration
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: [set by /dev-story when implementation begins]

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief MVP feature 6 — 舟への帰還による回収とスコア表示

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

- [ ] 画面に舟と「戻る」操作がある
- [ ] 戻る操作で、その時点の所持品(未回収の宝)が持ち帰り扱いになり、スコアに加算される
- [ ] 加算されるスコアは、持ち帰った宝の価値の合計である(価値はストーリー004のデータを使う)
- [ ] 戻る操作は、潮が満ちる前だけ有効である。満潮になっていれば失敗(ストーリー003)が優先する
- [ ] 帰還すると、今回の獲得スコアと、起動中の合計スコアが画面に表示される
- [ ] 失敗した場合は今回の獲得が0で、合計スコアは変わらない(宝はすべて失う)
- [ ] 成功と失敗の結果が、画面で見分けられる
- [ ] 合計スコアは起動中のみ保持し、保存しない(セーブ機能は作らない)
- [ ] 上陸 → 掘る → 戻る → 結果の1周が、通しで遊べる

---

## Implementation Notes

- **仮定(要確認)**: ブリーフには「舟へ戻る」操作の具体が書かれていない。このストーリーは「戻る」ボタンで即時に帰還が成立する(移動時間なし)と仮定している。移動や距離を加えたい場合は、実装前にこのストーリーを直すこと。
- 帰還が成立したら、ストーリー003の「舟に戻った」フラグを立てる。
- 回収は所持品(ストーリー004)から合計スコアへ移す処理にし、スコア計算は画面から分離して単体テストできるようにする。
- 結果画面はタップしやすい大きさにする(`technical-preferences.md` の Platform Notes)。

---

## Out of Scope

*Handled by neighbouring stories — do not implement here:*

- Story 003: 満潮の判定と失敗状態そのもの
- Story 007: 結果画面からのリスタート
- ハイスコアの保存、ランキング(MVP 外)

---

## Files

- `src/run/boat.gd`
- `src/run/score.gd`
- `src/ui/score_panel.gd`
- `src/ui/result_screen.tscn`
- `tests/integration/run/boat_return_test.gd`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*Governed by `qa.level`: at `qa.level: minimal` tests are **waived** (advisory), but a retained screenshot of anything the player sees is not.*

**Story Type**: Integration
**Required evidence**:
- `tests/integration/run/boat_return_test.gd` OR a playtest note — advisory at `qa.level: minimal`
- 成功時と失敗時の結果画面のスクリーンショット: `production/qa/evidence/story-006-boat-return-and-score.png`

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/pocket-island/story-003-tide-timer.md`, `production/epics/pocket-island/story-004-treasures-and-trap.md`
- Unlocks: `production/epics/pocket-island/story-007-instant-restart.md`
