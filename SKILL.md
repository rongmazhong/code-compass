---
name: code-compass
description: |
  个人 skill 库与 CLI 的总入口。融合 superpowers / gstack / OpenSpec / develop-workflow-rong。
  当用户希望启用 code-compass、运行其命令（use-code-compass / init / design / dev），
  或在会话中需要按本库方法论（柏拉图式发问、spec 驱动开发、状态机编排）工作时加载。
---

# code-compass

个人 skill 库与 CLI，提供一套 spec 驱动的开发方法论。

## 四个核心命令

| 命令 | skill 指引 | 作用 |
|------|-----------|------|
| `use-code-compass` | `skills/use-code-compass/SKILL.md` | 注册并启用库（软链 skills 到 agent 技能目录） |
| `init` | `skills/init/SKILL.md` | 初始化 `.harness/` 与 `openspec/`，注入 AGENTS.md |
| `design` | `skills/design/SKILL.md` | 柏拉图式发问 → 需求范围 → spec 文档 |
| `dev` / `develop` | `skills/dev/SKILL.md` | 基于 spec 的开发实现 |
| `wiki [topic]` | `skills/wiki/SKILL.md` | 更新/重建项目 wiki（docs/） |

## 使用方式

agent 加载本 skill 后，依据用户意图选择对应子命令：
- 新建/接入项目 → `init`
- 需求不明确 → `design`（柏拉图式发问）
- 已有 spec 要落地 → `dev`

每个子命令的详细方法论见 `skills/<name>/SKILL.md`。阶段进度统一维护在
`.harness/state/workflow-state.json`，阶段链：
`idea → design → planned → dev → implemented → qa → verified → reviewed → shipped`。

## 设计融合

- **superpowers**：方法论优先（先理解再实现、TDD、系统化调试、验证）
- **gstack**：QA 用 agent-browser，审查用 review + codex，发布用 /ship
- **OpenSpec**：`openspec/changes/<slug>/` 的 proposal + tasks + spec delta
- **develop-workflow-rong**：状态机阶段即编排依据，支持断点续跑
