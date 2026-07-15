# Change: sop-tiers

## Why

> 当前所有变更被强制走 9 阶段固定链，无论轻重。product-analysis 步骤 1 已判定 tier（研究型/小特性/中特性/大特性/重构），但判定结果**不影响后续阶段链**，导致轻量变更（hotfix、小文档、小重构）也要跑完完整流程，用户倾向用 `--force`/`--exempt` 绕过，削弱方法论权威性。

- 问题本质：tier 判定与阶段链解耦，缺"按档位裁剪阶段"的机制。
- 用户对象：使用 code-compass 的 AI agent 与开发者。
- 范围边界（MVP 必含）：tracks 映射定义、product-analysis 选定 track、status/guard 按 track 渲染与校验。
- 非目标：不重排阶段语义；不自动改写既有变更的 stage；不引入新的并行/分支模型（见 parallel-state 变更）。
- 成功信号：运行 `code-compass status` 时，小特性变更的阶段链不含 `reviewed`；research 变更链仅到 `summary`；`guard` 对裁剪掉的阶段不报错。

## What Changes

> 触及能力：stage-tracks（阶段链按 tier 裁剪的轨道机制）。

## Impact

> 影响范围：`.harness/config.json`（`stages` 之外新增 `tracks`）、`skills/code-compass/code-compass` 的 `product-analysis`/`status`/`guard` 命令、`workflow-state.json` schema（新增 `track` 字段）。
