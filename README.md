# code-compass

一个融合 **superpowers / gstack / OpenSpec / develop-workflow-rong** 的个人 skill 库与 CLI。
它不是堆功能，而是一套"先理解问题、再 spec 驱动实现"的工程方法论编排器。

## 核心思想

| 来源 | 贡献 |
|------|------|
| **superpowers** | 方法论优先：brainstorm / TDD / 系统化调试 / 计划驱动 |
| **gstack** | 角色化虚拟团队、QA（agent-browser）、审查（review + codex）、发布（/ship） |
| **OpenSpec** | spec 驱动的变更管理：`specs/`（truth）+ `changes/`（proposal + tasks + delta） |
| **develop-workflow-rong** | 自动状态机编排：`.harness/state/workflow-state.json` 阶段推进 |

## 安装

```bash
git clone git@github.com:rongmazhong/code-compass.git
cd code-compass
chmod +x code-compass
```

## 命令

| 命令 | 作用 |
|------|------|
| `code-compass use-code-compass` | 注册并启用 skill 库（将 `skills/` 软链到 agent 技能目录 `~/.agents/skills`，并确保目标项目已 `init`） |
| `code-compass init` | 在当前项目初始化 `.harness/`（state + rules）、`openspec/` 骨架，并向 `AGENTS.md` 注入路由 |
| `code-compass design [name]` | 柏拉图式（苏格拉底式）发问，确定需求范围，生成 OpenSpec 风格的 spec 文档 |
| `code-compass dev\|develop [name]` | 基于 spec 进行开发实现（计划 → TDD → 子代理 → 验证） |

## 典型流程

```bash
code-compass use-code-compass     # 启用库
cd your-project && code-compass init
code-compass design my-feature    # 发问 → openspec/changes/my-feature/
code-compass dev my-feature       # 实现 → 推进 workflow-state
```

## 目录结构

```
code-compass/
├── README.md
├── SKILL.md                 # 顶层 skill：加载整个库的总说明
├── code-compass             # CLI 可执行
├── skills/                  # 各命令/能力的方法论（agent 可读）
│   ├── use-code-compass/SKILL.md
│   ├── init/SKILL.md
│   ├── design/SKILL.md
│   └── dev/SKILL.md
├── harness/                 # init 注入目标项目的模板
│   ├── AGENTS.md.harness
│   ├── config.json
│   └── workflow-state.json
├── openspec/                # 本库自身的 spec 存储（兼作模板范例）
│   ├── project.md
│   └── README.md
└── templates/              # design/dev 生成的文档模板
    ├── proposal.md
    ├── tasks.md
    └── spec.md
```

目标项目被 `init` 后会产生：

```
your-project/
├── .harness/
│   ├── config.json
│   ├── state/workflow-state.json
│   └── rules/{structure.md,workflow.md,coding.md}
├── openspec/
│   ├── project.md
│   ├── specs/
│   └── changes/<slug>/{proposal.md,tasks.md,specs/}
└── AGENTS.md                # 已注入 code-compass 路由段
```

## 阶段状态机

`.harness/state/workflow-state.json` 记录进度，中断后可从断点续跑：

```
idea → design → planned → dev → implemented → qa → verified → reviewed → shipped
```

## License

MIT
