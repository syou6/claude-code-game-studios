# Epic: pocket-island

> **Source**: `design/game-brief.md` (workflow: minimal — no GDD, ADRs or layers)
> **Engine**: Godot 4.7.2 (GDScript)

## Goal

毎回形の変わる小さな島を掘り進め、潮が満ちる前に宝を抱えて舟へ戻る、5分で一周のローグライク宝探し。

## Scope

ブリーフの MVP 7 項目を、Build order の順に実装する。

- 手続き生成される小さな島(格子状)
- 掘るアクション
- 潮位タイマーと満潮時の失敗判定
- 宝3種と罠1種
- シャベル強化
- 舟への帰還による回収とスコア表示
- 即時リスタート

Out of scope: セーブ・永続強化、敵・戦闘、複数ステージ、マルチプレイ、ストーリー・NPC。

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | 格子状の島を生成して表示する | Logic | Ready | N/A |
| 002 | タイルを掘って中身を判明させる | Logic | Ready | N/A |
| 003 | 潮位タイマーと満潮時の失敗判定 | Logic | Ready | N/A |
| 004 | 宝3種と罠1種 | Logic | Ready | N/A |
| 005 | シャベル強化(掘れる範囲の拡大) | Logic | Ready | N/A |
| 006 | 舟への帰還による回収とスコア表示 | Integration | Ready | N/A |
| 007 | 即時リスタート(次の島へ) | Logic | Ready | N/A |
