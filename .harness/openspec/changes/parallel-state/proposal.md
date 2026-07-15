# Change: parallel-state

## Why

> 当前 `.harness/state/workflow-state.json` 为单一全局文件，仅能记录一个 `stage`/`spec`/`branch`。当项目并行推进多个变更（如同时存在 `cli-robustness-hardening` 与 `using-code-compass-onboard`）时，全局"活跃阶段指针"会被后写的变更覆盖，无法表达"A 在 dev、B 在做 product-analysis"的真实状态。spec 本体虽已是 per-slug（`changes/<slug>/`），但阶段指针是单点瓶颈。

- 问题本质：状态存储是"单活跃指针 + 单阶段"，不支持多变更并存。
- 用户对象：并行开发多需求的 AI agent / 开发者。
- 范围边界（MVP 必含）：状态改为 `active` + `changes{slug:{...}}` 内嵌多对象；status/guard 作用于 active；`status --all` 列出全部。
- 非目标：不实现变更间依赖图；不自动切换 active；不做并发锁。
- 成功信号：`code-compass status --all` 能同时显示两个变更的各自阶段；切换 active 后 `guard` 校验对应变更。

## What Changes

> 触及能力：state-store（多变更状态存储）。

## Impact

> 影响范围：`.harness/state/workflow-state.json` schema（重构为 `{active, changes}`）、`skills/code-compass/code-compass` 中所有读写状态的函数（`_set_stage`/`_json_get` 调用处/`status`/`guard`/`product-analysis`/`dev`）。

## Dependencies / Ordering

> **与 sop-tiers 的交互**：sop-tiers 引入的 `track` 字段 SHALL 存放于 `changes[active].track`（而非顶层）。建议实现顺序：parallel-state 先于 sop-tiers 落地；若 sop-tiers 先行，其 `_set_track` 在 parallel-state 合并后须改为写入 `changes[active].track`。
