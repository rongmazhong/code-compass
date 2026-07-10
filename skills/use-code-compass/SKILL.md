---
name: use-code-compass
description: |
  注册并启用 code-compass 个人 skill 库。当用户运行 `code-compass use-code-compass`、
  或希望在会话中启用 code-compass 的 skill 触发能力时使用。该命令将 skills/ 下的
  所有 skill 软链到 agent 的技能目录，并确保目标项目已初始化 .harness/。
---

# use-code-compass

启用 code-compass 个人 skill 库的总开关。运行后，agent 即可通过 `skill` 工具
  加载 `init` / `product-analysis` / `dev` 等 skill，并根据其触发条件自动或按需调用。

## 触发条件

- 用户运行 `code-compass use-code-compass`
- 用户说"启用 code-compass"、"加载我的 skill 库"
- 会话开始时希望启用本库的方法论编排

## 执行流程

1. 运行 `code-compass use-code-compass`（CLI 会：）
   - 将 `skills/*` 软链到 `$CODE_COMPASS_SKILLS_DIR`（默认 `~/.agents/skills`）
   - 若目标项目没有 `.harness/`，自动执行 `init`
   - 打印已注册 skill 列表与触发方式
2. 确认 AGENTS.md 中已注入 code-compass 路由段（init 负责）
3. 此后 agent 遇到匹配场景时，直接 `skill` 工具加载对应 `SKILL.md`

## 与其他方法论的关系

- **superpowers**：本库的 skill 遵循其"方法论优先"原则（先理解再实现、TDD、系统化调试）
- **gstack**：发布/审查阶段可调用 gstack 的 `/ship`、`review`、`codex` 等
- **openspec**：`product-analysis` 产出的 spec 与 `dev` 消费的 spec 均存放于 `openspec/`
- **develop-workflow-rong**：`.harness/workflow-state.json` 复用其状态机思路做阶段编排
