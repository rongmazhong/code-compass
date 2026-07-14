---
name: code-compass
description: >
   code-compass 总入口：spec 驱动、状态机编排、先分析后开发的强制约束方法论库。用户要启用本库、运行其命令（init / product-analysis / dev / guard 等）或按本库方法论工作时加载。
---

# code-compass

个人 skill 库与 CLI，提供一套 spec 驱动、状态机编排的开发方法论。
**方法论是默认硬约束**：动手写代码前必须先经 `product-analysis` 生成已确认 spec，
`code-compass guard` 会在阶段不符时拦截偏离。

## 安装与启用

本 skill 通过 skills 注册表分发，安装后完整工具位于 `~/.agents/skills/code-compass/`：

```bash
npx skills add rongmazhong/code-compass
# 让 code-compass 命令可用（二选一，本工具不创建任何软链）：
#   a) alias 到 shell 配置：  alias code-compass="$HOME/.agents/skills/code-compass/code-compass"
#   b) 或加入 PATH：          export PATH="$HOME/.agents/skills/code-compass:$PATH"
code-compass using-code-compass      # 校验安装并完成当前项目初始化
```

## 核心命令

| 命令 | skill 指引 | 作用 |
|------|-----------|------|
| `using-code-compass` | `skills/using-code-compass/SKILL.md` | 注册并启用库（校验已全局安装，并确保项目已 init） |
| `init` | `skills/init/SKILL.md` | 初始化 `.harness/`（含 state/rules/openspec），注入 AGENTS.md |
| `product-analysis` | `skills/product-analysis/SKILL.md` | 柏拉图式发问 → 需求范围 → spec 文档 |
| `dev` / `develop` | `skills/dev/SKILL.md` | 基于 spec 的开发实现（自动 git worktree 隔离） |
| `worktree [list\|prune]` | — | 管理开发用 git worktree |
| `vapd [ID]` | `skills/commit/SKILL.md` | 记录/查看 VAPD 标识（VR需求/VB缺陷/VT任务） |
| `commit <type> <描述>` | `skills/commit/SKILL.md` | 按 `<type>: #{VAPD_ID}#<描述>` 规范提交（含阶段校验） |
| `status [activate]` | `skills/status/SKILL.md` | 查看状态 / 激活当前阶段自动化流程 |
| `guard` | `skills/guard/SKILL.md` | 闸门校验：当前阶段是否允许动手，偏离则拦截 |
| `wiki [topic]` | `skills/wiki/SKILL.md` | 更新/重建项目 wiki（docs/） |

## 使用方式

方法论是**默认硬约束**：任何代码改动意图，先走 `product-analysis → planned → dev` 阶段机，
未生成 spec 不得直接编码。agent 加载本 skill 后，依据用户意图选择对应子命令：
- 新建/接入项目 → `init`（注入强制约束、引导补全 overview、生成 rules/guard.md）
- 需求不明确 / 用户说"新功能、做客户端、实现 X" → `product-analysis`（柏拉图式发问）
- 动手前闸门校验 → `guard`（偏离会拦截，exit 非 0）
- 已有 spec 要落地 → `dev`（阶段未到 planned 会被拦截，可用 `dev --force` 豁免）

每个子命令的详细方法论见 `skills/<name>/SKILL.md`。阶段进度统一维护在
`.harness/state/workflow-state.json`，阶段链：
`idea → product-analysis → planned → dev → implemented → qa → verified → reviewed → summary`。

## 设计融合

> 以下为方法论**灵感来源**（可选增强，非强制依赖）：code-compass 已将其内化为自包含的 skill 工作流，单独使用即可跑通全流程。

- **superpowers**：方法论优先（先理解再实现、TDD、系统化调试、验证）
- **gstack**：QA 用 agent-browser，审查用 review + codex，发布用 /ship
- **OpenSpec**：`.harness/openspec/changes/<slug>/` 的 proposal + tasks + spec delta
- **develop-workflow-rong**：状态机阶段即编排依据，支持断点续跑
