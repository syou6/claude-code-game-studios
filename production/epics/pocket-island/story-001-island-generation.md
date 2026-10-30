# Story 001: 格子状の島を生成して表示する

> **Epic**: pocket-island
> **Status**: Complete
> **Layer**: N/A (minimal — no layers)
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-30

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief MVP feature 1 — 手続き生成される小さな島(格子状、毎回地形と宝の配置が変わる)

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

- [ ] 島のサイズ(列数・行数)は外部データファイルから読み込まれ、コードに直書きされない
- [ ] 生成は乱数シードを受け取り、同じシードなら同じ島になり、違うシードなら地形が変わる
- [ ] 島は格子状で、各タイルは「陸」か「海」のどちらかである
- [ ] 陸タイルはすべて連結していて、孤立した陸がない
- [ ] 舟の位置(スタート位置)が島に1つ決まり、陸に隣接している
- [ ] 陸タイルは中身を後から設定できる(このストーリーでは空のまま生成してよい)
- [ ] 起動すると島が格子として画面に表示され、陸タイルと海タイルが見分けられる
- [ ] 島全体が画面内に収まり、見切れない

---

## Implementation Notes

- コードは `src/island/` に置く。データモデルと生成ロジックは画面表示から分離し、単体テストできるようにする(依存注入、シングルトンに頼らない)。
- 島のサイズなどの値は `assets/data/` のデータファイルに置く(コードに直書きしない)。
- 起動時に島が表示されるよう、メインシーンを作り `project.godot` の `run/main_scene` に設定する(現在は未設定)。
- 乱数は `RandomNumberGenerator` にシードを渡して使い、テストが毎回同じ結果になるようにする。
- 命名は `.claude/docs/technical-preferences.md` に従う(スクリプトとシーンは snake_case)。

---

## Out of Scope

*Handled by neighbouring stories — do not implement here:*

- Story 002: タイルを掘る操作
- Story 004: 宝・罠・空の中身の種類と配置
- Story 006: 舟へ戻る操作

---

## Files

- `src/island/island_grid.gd` — created (island data model)
- `src/island/island_generator.gd` — created (seeded generation, boat placement)
- `src/island/island_view.gd` — created (draws the grid, fits any window)
- `src/main.gd` — created (reads config, picks seed, composes)
- `src/main.tscn` — created (main scene)
- `assets/data/island_config.json` — created (island tuning values)
- `assets/data/island_config.md` — created (schema for the JSON)
- `project.godot` — modified (run/main_scene)
- No test file: waived at `qa.level: minimal`

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*Governed by `qa.level`: at `qa.level: minimal` tests are **waived** (advisory), but a retained screenshot of anything the player sees is not.*

**Story Type**: Logic
**Required evidence**:
- `tests/unit/island/island_generator_test.gd` — advisory at `qa.level: minimal`
- 起動して島が表示された画面の保存済みスクリーンショット: `production/qa/evidence/story-001-island-generation.png`(手順は `.claude/docs/run-and-observe.md`)

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: None
- Unlocks: `production/epics/pocket-island/story-002-dig-action.md`

---

## Completion Notes
**Completed**: 2026-10-30
**Criteria**: 8/8 passing (none deferred)
**Deviations**: ADVISORY — 色と枠の余白の定数 4 つが `src/island/island_view.gd` のコード内にある(見た目の値)。ADVISORY — AC-8 は 1152×648 の横長でのみ確認、縦長のスマホ画面は未確認。OUT OF SCOPE — Godot が自動生成する `.uid` ファイル 4 つと `.godot/global_script_class_cache.cfg` がコミットに含まれる。舟は「外海から届く岸」に限定した(基準より 1 段厳しい)。
**Test Evidence**: waived at qa.level minimal。保存済みスクリーンショットは `production/qa/evidence/story-001-island-generation/01-island-launch.png`(上の Required evidence に書かれたパスは、フォルダ名を欠いた古い表記)
**Reviewed by**: self, no independent review
