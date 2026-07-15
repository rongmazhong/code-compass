# Change: init-detect

## Why

> `code-compass init` 的项目探测 `_detect_project`（`:867`）仅识别 go/package.json/pyproject 三类，导致纯 bash、Rust、DotNet、Makefile 驱动等项目初始化后 `语言：未知`，且 `rules/workflow.md` 的构建/测试/lint 字段恒为"（未识别，请补充）"占位。wiki 与 qa 自动化（qa-automation 变更）因此缺乏真实命令源。

- 问题本质：init 探测信号过窄，且无失败时显式标注、无命令预填。
- 用户对象：初始化新项目的 AI agent / 开发者。
- 范围边界（MVP 必含）：扩充信号、失败显式标注、识别包管理器时预填 workflow.md 命令。
- 非目标：不实现交互式问答补全（可后续增强）；不重写 wiki 生成逻辑。
- 成功信号：对 Rust 项目 init 后 `语言：Rust` 且 workflow.md 含 `cargo test`；对无法识别项目显式标注"未识别（请手动填写）"。

## What Changes

> 触及能力：init-detect（初始化项目探测增强）。

## Impact

> 影响范围：`skills/code-compass/code-compass` 的 `_detect_project` 及 init 时 `rules/workflow.md` 模板填充逻辑。

## Dependencies / Ordering

> 为 qa-automation 提供真实命令源（workflow.md 不再恒为占位）。
