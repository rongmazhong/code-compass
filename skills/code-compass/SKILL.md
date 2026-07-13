---
name: code-compass
description: |
  个人 skill 库与 CLI 的总入口。借鉴 superpowers / gstack / OpenSpec / develop-workflow-rong 的方法论（均已内化为自包含流程，非强制依赖）。
   当用户希望启用 code-compass、运行其命令（use-code-compass / init / product-analysis / dev），
  或在会话中需要按本库方法论（柏拉图式发问、spec 驱动开发、状态机编排）工作时加载。
---

# code-compass

个人 skill 库与 CLI，提供一套 spec 驱动的开发方法论。

## 安装与启用

本 skill 通过 skills 注册表分发，安装后完整工具位于 `~/.agents/skills/code-compass/`：

```bash
npx skills add rongmazhong/code-compass
# 让 code-compass 命令可用（一次性）
ln -sfn ~/.agents/skills/code-compass/code-compass ~/.local/bin/code-compass
code-compass use-code-compass      # 链接子 skill 并完成当前项目初始化
```

> 运行 `use-code-compass` 时也会自动补建上面的软链。若 `~/.local/bin` 不在 PATH，请将其加入 shell 配置。

## 四个核心命令

| 命令 | skill 指引 | 作用 |
|------|-----------|------|
| `use-code-compass` | `skills/use-code-compass/SKILL.md` | 注册并启用库（软链 skills 到 agent 技能目录） |
| `init` | `skills/init/SKILL.md` | 初始化 `.harness/`（含 state/rules/openspec），注入 AGENTS.md |
| `product-analysis` | `skills/product-analysis/SKILL.md` | 柏拉图式发问 → 需求范围 → spec 文档 |
| `dev` / `develop` | `skills/dev/SKILL.md` | 基于 spec 的开发实现（自动 git worktree 隔离） |
| `worktree [list\|prune]` | — | 管理开发用 git worktree |
| `vapd [ID]` | `skills/commit/SKILL.md` | 记录/查看 VAPD 标识（VR需求/VB缺陷/VT任务） |
| `commit <type> <描述>` | `skills/commit/SKILL.md` | 按 `<type>: #{VAPD_ID}#<描述>` 规范提交 |
| `status [activate]` | `skills/status/SKILL.md` | 查看状态 / 激活当前阶段自动化流程 |
| `wiki [topic]` | `skills/wiki/SKILL.md` | 更新/重建项目 wiki（docs/） |

## 使用方式

agent 加载本 skill 后，依据用户意图选择对应子命令：
- 新建/接入项目 → `init`
- 需求不明确 → `product-analysis`（柏拉图式发问）
- 已有 spec 要落地 → `dev`

每个子命令的详细方法论见 `skills/<name>/SKILL.md`。阶段进度统一维护在
`.harness/state/workflow-state.json`，阶段链：
`idea → product-analysis → planned → dev → implemented → qa → verified → reviewed → summary`。

## 设计融合

> 以下为方法论**灵感来源**（可选增强，非强制依赖）：code-compass 已将其内化为自包含的 skill 工作流，单独使用即可跑通全流程。

- **superpowers**：方法论优先（先理解再实现、TDD、系统化调试、验证）
- **gstack**：QA 用 agent-browser，审查用 review + codex，发布用 /ship
- **OpenSpec**：`.harness/openspec/changes/<slug>/` 的 proposal + tasks + spec delta
- **develop-workflow-rong**：状态机阶段即编排依据，支持断点续跑
