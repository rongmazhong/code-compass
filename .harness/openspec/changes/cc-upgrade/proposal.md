# Change: cc-upgrade

## Why

> 柏拉图式发问的结论。说明真正要解决的问题、用户对象、成功信号。明确"不做什么"。

- 问题本质：
  code-compass 只有首启 `init`（幂等、绝不覆盖），**没有"升级 / 迁移"路径**。
  当用户通过 `npx skills add rongmazhong/code-compass` 拉取新版本后，安装目录 `~/.agents/skills/code-compass/`
  被刷新，但每个**已存在项目**的 `.harness/` 仍停留在旧模板：
  - `config.json` 可能缺 `tracks`（sop-tiers 之后才有）→ `status activate` / `guard` 的 track 感知裁剪静默失效；
  - `workflow-state.json` 缺 `updated_at` 等新增字段，schema 漂移；
  - `_state_migrate` 只处理"远古无 `changes`"的旧结构，对"有 `changes` 但缺新字段"无能为力。
  `init` 因幂等不会修正这些。结果是：升级 code-compass 后，老项目**静默丢失能力**，无命令可修复。

- 用户对象：
  已用 code-compass 管理 ≥1 个项目、并通过 npx 升级 skill 库的开发者。

- 范围边界（MVP 必含 / 后置）：
  - 必含：`code-compass upgrade` 命令，刷新**当前项目**的 harness **配置**（仅 `config.json` + `workflow-state.json`），保留全部用户数据，幂等。
  - 后置（不在本变更）：自动在每次命令时检测漂移；`rules/` 与 `AGENTS.md` 的刷新。

- 非目标：
  - 不刷新 `rules/`、`AGENTS.md` 路由段（按你的取舍：升级范围=仅 harness 配置）。
  - 不自动运行，不静默改用户项目；`upgrade` 是显式、用户逐项目触发的命令。
  - 不做跨项目全局扫描（code-compass 一次只作用于 `TARGET_DIR` 当前项目）。

- 安装级（npx 重跑的自定保留）：
  用户重跑 `npx skills add` 会覆盖 skill 库，其在 `SKILL.md` / `rules/` 的自定修改应**备份 + 合并**。
  本变更将之作为设计约束：v1 聚焦**项目级** harness 刷新（已验证的高价值缺口）；
  安装级自定合并以 `upgrade --self`（可选、需配置 `upgrade_source`）承载，v1 给出骨架与约束，不强制拉取。

- 成功信号：
  升级 code-compass 后，用户在老项目里跑一次 `code-compass upgrade`，
  `config.json` 含正确 `tracks`、`workflow-state.json` 含 `updated_at`，且原有 `changes` 状态 / `issues.md` / `openspec/` 内容零丢失；重复运行幂等无副作用。
