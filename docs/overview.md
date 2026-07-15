# 项目概览

> 由 code-compass 生成，已根据本项目实际情况补全。

## 这是什么

code-compass 是一套**个人 skill 库 + CLI**，提供 spec 驱动、状态机编排的开发方法论。
它把"先分析后开发"硬化为硬约束：动手写代码前必须先经 `product-analysis` 生成已确认
spec，`code-compass guard` 会在阶段不符时拦截偏离。

- 面向谁：使用 Claude / opencode 等 agent 的开发者，想用统一方法论管理多项目开发流程。
- 解决什么：避免"跳过分析就直接编码"，提供 idea→planned→dev→…→summary 的阶段机、
  VAPD 标识、规范化提交与断点续跑能力。

## 技术栈

- 语言：纯 Bash（POSIX 友好）；CLI 为**模块化脚本**（`code-compass` 主入口 + `lib/*.sh` 关注点库 + `lib/cmds/*.sh` 命令实现）
- 构建系统：无（不需要编译/依赖安装，分发给 agent 直接执行）
- 关键依赖：`jq`（解析 JSON 状态，缺失时回退 bash 实现）、git（worktree / 提交）、标准 Unix 工具
- 分发：通过 `npx skills add rongmazhong/code-compass` 安装到 `~/.agents/skills/code-compass/`

## 快速开始

```bash
npx skills add rongmazhong/code-compass
alias code-compass="$HOME/.agents/skills/code-compass/code-compass"
code-compass using-code-compass      # 校验安装并初始化当前项目
code-compass init                    # 在当前项目生成 .harness/ 与 docs/
```

- 构建：无需构建
- 测试：`bash skills/code-compass/tests/run_smoke.sh`（bats 未装时的等价冒烟；装了 `bats-core` 可跑 `tests/cli_modular.bats`）
- 运行：`code-compass <command>`

## 关键能力（已落地）

- **并行状态（parallel-state）**：`workflow-state.json` 内嵌多对象状态，支持 `status --all` 一览多变更。
- **SOP 档位（sop-tiers）**：`config.json` 定义 5 档 track（`research`/`small`/`standard`/`standard+`/`refactor`），
  不同档位裁剪阶段链（如 `small` 跳过 `review`）。
- **init 探测（init-detect）**：`init` 自动探测项目语言/构建/测试命令并预填 `rules/` 与 `AGENTS.md` 路由。
- **QA 自动化（qa-automation）**：`qa` / `verify` / `review` 三命令，按阶段推进状态机。
- **status 激活（status-activate-cmd）**：`status activate` 输出当前阶段可复制的下一步命令，按 track 裁剪。
- **product-analysis 提效（pa-efficiency）**：`--append` 仅追加澄清/决策到 `issues.md`，`--force` 跳过交互直接建变更工作区。
- **CLI 模块化（cli-modular）**：单文件巨石拆分为主入口 + `lib/` + `lib/cmds/`，行为不变。

## 相关文档

- 架构设计：architecture.md
- 核心模块：modules.md
- 功能与 API：api.md
- 下一步：运行 `code-compass product-analysis` 进入需求分析阶段
