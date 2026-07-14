---
name: using-code-compass
description: |
   注册并启用 code-compass 个人 skill 库（一键接入方法论编排）。当用户运行
   `code-compass using-code-compass`、或说"启用 code-compass / 加载我的 skill 库 / 接入指南针"时触发。
   该命令把库内 skills/ 全部软链到 agent 技能目录，确保目标项目已 `init`（注入强制约束），
   并打印各 skill 的触发方式，使后续"新功能 / 实现 X / 继续"等意图能按触发词映射自动调用对应 skill。
---

# using-code-compass

启用 code-compass 个人 skill 库的总开关。运行后，agent 即可通过 `skill` 工具
加载 `init` / `product-analysis` / `dev` / `guard` 等 skill，并按 AGENTS.md 中的
「触发词 → 必调 skill」映射，在匹配场景自动或按需调用。

## 触发条件

- 用户运行 `code-compass using-code-compass`（旧别名 `use-code-compass` / `use` 仍可用）
- 用户说"启用 code-compass"、"加载我的 skill 库"、"接入指南针"
- 会话开始时希望启用本库的方法论编排（先分析后开发的强制约束）

## 执行流程

1. 运行 `code-compass using-code-compass`（CLI 会：）
   - 将 `skills/*` 软链到 `$CODE_COMPASS_SKILLS_DIR`（默认 `~/.agents/skills`）
   - 若目标项目没有 `.harness/`，自动执行 `init`（注入强制约束段与 `rules/guard.md`）
   - 将 CLI 软链到 `~/.local/bin/code-compass`，使命令进入 PATH
   - 打印已注册 skill 列表与触发方式
2. 确认 AGENTS.md 中已注入 code-compass 强制约束段（init 负责）
3. 此后 agent 遇到匹配场景时，直接 `skill` 工具加载对应 `SKILL.md`

## 与其他方法论的关系

- **superpowers**：本库的 skill 遵循其"方法论优先"原则（先理解再实现、TDD、系统化调试）；以上为方法论来源，非强制依赖
- **gstack**：发布/审查阶段可调用 gstack 的 `/ship`、`review`、`codex` 等（可选增强，非强制依赖）
- **openspec**：`product-analysis` 产出的 spec 与 `dev` 消费的 spec 均存放于 `.harness/openspec/`
- **develop-workflow-rong**：`.harness/workflow-state.json` 复用其状态机思路做阶段编排（已内置，非加载该 skill）
