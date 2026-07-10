---
name: init
description: |
  在当前项目初始化 code-compass 运行环境。当用户运行 `code-compass init`、
  或在新项目开始使用 code-compass 时触发。创建 .harness/ 目录（config + workflow-state）、
  openspec/ 骨架，并向 AGENTS.md 注入 code-compass 路由指引。
---

# init

为当前项目铺设 code-compass 的运行基座：状态目录、spec 存储与 agent 路由。

## 触发条件

- 用户运行 `code-compass init`
- 用户在新仓库中首次使用 code-compass
- `use-code-compass` 检测到目标项目缺少 `.harness/`

## 执行流程

1. 创建 `.harness/` 目录，写入：
   - `config.json`：工具元信息（name、version、skills 目录约定）
   - `workflow-state.json`：初始阶段 `idea`，记录 `completed` / `spec` / `branch` / `updated_at`
2. 创建 `openspec/` 骨架：
   - `openspec/specs/`：当前能力 spec（truth）
   - `openspec/changes/`：待实现的变更提案
   - `openspec/project.md`：项目级上下文
3. 向 `AGENTS.md` 注入 code-compass 路由段（用 `MARKER` 包裹，避免重复）：
   - 说明四个命令：`use-code-compass` / `init` / `design` / `dev`
   - 说明 `.harness/workflow-state.json` 的阶段含义

## 不覆盖原则

- 已存在的 `config.json` / `workflow-state.json` / `project.md` 不覆盖
- 已注入路由段的 `AGENTS.md` 跳过注入，仅追加一次

## 阶段状态（workflow-state.json）

```dot
digraph cc {
  rankdir=LR;
  idea -> design -> planned -> dev -> implemented -> qa -> verified -> reviewed -> shipped;
}
```
