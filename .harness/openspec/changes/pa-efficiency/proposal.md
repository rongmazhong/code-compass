# Change: pa-efficiency

## Why

> `product-analysis` 步骤 3 强制"每轮只问一个问题，不限轮数"。对复杂/多维度需求，这会导致 10+ 轮澄清对话，大量消耗 AI agent 上下文窗口，并在步骤 4-5 时促使用者选择"直接做吧"而偏离方法论。

- 问题本质：澄清策略过于保守，未随 tier 弹性，也无快速通道。
- 用户对象：运行 product-analysis 的 AI agent 与需求方。
- 范围边界（MVP 必含）：按 tier 弹性提问上限 + 清晰描述/PRD 的快速通道。
- 非目标：不改变"需求清晰、边界明确、非目标清楚、成功信号可观测"的停止条件；不删除对抗验证步骤。
- 成功信号：小特性澄清轮次显著下降；附带 PRD 时可直接进入步骤 4。

## What Changes

> 触及能力：pa-efficiency（需求分析澄清效率）。

## Impact

> 影响范围：`skills/code-compass/skills/product-analysis/SKILL.md` 步骤 3 文案与判定指引。

## Dependencies / Ordering

> 与 sop-tiers 共用 tier 概念；本变更只是 SKILL.md 文案/指引调整，不依赖其实现。
