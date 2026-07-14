# >>> code-compass >>>
# code-compass 路由（强制约束）

> ⚠️ **本段不是可选的「建议」，而是本项目开发流程的硬约束。**
> 任何代码改动意图，默认必须先走 `product-analysis → planned → dev` 阶段机；
> 未经分析直接落地的改动视为偏离方法论，会被 `code-compass guard` / `commit` 拦截。

本项目的开发流程由 [code-compass](https://github.com/rongmazhong/code-compass) 驱动，
方法论融合 superpowers / gstack / openspec / develop-workflow-rong。

## 强制默认：先分析后开发

agent 在动手写代码**之前**，必须确认 `.harness/state/workflow-state.json` 的 `stage`
已到达 `planned` 或更后，且已存在 `.harness/openspec/changes/<slug>/` 下的 spec。
否则视为「偏离方法论」，应先运行 `product-analysis` 收敛需求、生成 spec，**不得直接编辑实现**。

- 阶段链：`idea → product-analysis → planned → dev → implemented → qa → verified → reviewed → summary`
- 处于 `idea` / `product-analysis` 阶段 = 尚未确认 spec，**禁止进入编码**。
- 动手前先跑 `code-compass guard`（或 `code-compass status --guard`）做闸门校验。

## 触发词 → 必调 skill（硬映射）

agent 检测到对应意图时，**优先**调用右侧 skill，而非直接编辑文件：

| 用户意图 / 触发词 | 必调 skill | 约束 |
|-------------------|-----------|------|
| 新功能 / 做客户端 / 加能力 / 实现 X / 需求 | `product-analysis` | 先发问收敛需求、生成 spec；**禁止直接编辑实现** |
| 改需求 / 调范围 / 设计一下 / 出方案 | `product-analysis` | 同上 |
| 按 spec 实现 / 开始开发 / 进入开发 | `dev` | 需先有 spec 且 `stage=planned` 或更后 |
| 提交 / commit / 按规范提交 | `commit` | 强制 `<type>: #{VAPD_ID}#<描述>` |
| 查看进度 / 现在到哪 / 继续流程 | `status` / `status activate` | 仪表盘 + 续跑 |
| 我要动手 / 是否可编码 / 校验阶段 | `guard`（`status --guard`） | 校验阶段，偏离则拦截 |

## 「继续 / 直接做」闸门（硬规则）

当 `workflow-state.json` 的 `stage` 仍位于 `idea` 或 `product-analysis`（尚未生成已确认 spec）时，
用户说「继续 / 直接做 / 做吧 / 落地 / 你看着办」等，**agent 不得直接进入编码**。必须先：

1. 运行 `code-compass guard` 校验当前阶段；
2. 若校验未通过：先产出 spec 骨架（`product-analysis`）或一份澄清清单，再继续；
3. 只有 `stage` 到达 `planned` 且 spec 就绪，才允许进入 `dev`。

软纪律已硬化为硬约束——「凭经验落地」在尚未分析时不被允许。

## 偏离提醒（显式拦截）

若 agent 准备写代码而 `state` 仍处 `idea` / `product-analysis`，`code-compass guard`
会输出**黄色提醒**并以非 0 退出（视为偏离）。agent 应停下，先走 `product-analysis`，
或显式使用豁免（见下）并说明原因。

## 豁免机制

仅在以下情况可绕过闸门（需在回复中说明豁免理由）：

- `code-compass dev --force`：强制进入开发（已知 spec 在脑中/极小改动）。
- `code-compass commit --exempt <type> <描述>`：跳过提交期阶段校验（如一次性脚手架、hotfix）。
- 环境变量 `CODE_COMPASS_GUARD=off` 关闭全部闸门（不推荐，仅调试用）。

## 命令

| 命令 | 作用 |
|------|------|
| `code-compass using-code-compass` | 注册并启用 skill 库（校验已全局安装，并确保项目已 init） |
| `code-compass init` | 初始化 `.harness/`（含 state/rules/openspec），并注入本段 |
| `code-compass product-analysis [name]` | 柏拉图式发问，确定需求范围并生成 spec（**默认第一步**） |
| `code-compass dev [name]` | 基于 spec 进行开发实现（自动创建 git worktree） |
| `code-compass guard` | 闸门校验：当前阶段是否允许动手，偏离则拦截 |
| `code-compass worktree [list|prune]` | 管理开发用 git worktree |
| `code-compass vapd [ID]` | 记录/查看 VAPD 标识（VR需求/VB缺陷/VT任务），写入 state |
| `code-compass commit <type> <描述>` | 按 `<type>: #{VAPD_ID}#<描述>` 规范提交（含阶段校验） |
| `code-compass status [activate]` | 查看当前状态；`activate` 激活当前阶段自动化流程 |
| `code-compass wiki [topic]` | 更新/重建项目 wiki（`docs/`） |

## 提交规范

所有 git 提交必须遵循：`<type>: #{VAPD_ID}#<描述>`（type: feat/fix/docs/refactor 等）。
VAPD_ID 取自 `.harness/state/workflow-state.json` 的 `vapd_id`（需求 VR / 缺陷 VB / 任务 VT 开头），
由 product-analysis 阶段显式记录；未记录时退化为 `<type>: <描述>`。统一用
`code-compass commit <type> <描述...>` 提交，避免手写 `git commit -m` 漏带标识。

`commit` 会在提交前校验阶段：处于 `idea` / `product-analysis` 阶段直接提交实现代码会被拦截
（除非带 `--exempt` 豁免），从源头杜绝「跳过分析就开发」。

## 阶段状态

开发进度记录在 `.harness/state/workflow-state.json`，阶段链：

```
idea → product-analysis → planned → dev → implemented → qa → verified → reviewed → summary
```

## 项目规则

项目级规则位于 `.harness/rules/`，agent 在开发与审查时应遵循：

- `rules/structure.md` —— 项目工程结构定义（技术栈、目录职责）
- `rules/workflow.md`  —— 开发流程（构建/测试/检查命令、分支与提交约定）
- `rules/coding.md`   —— 编码约束（通用原则 + 语言相关规则）
- `rules/guard.md`    —— 方法论强制契约（闸门、触发映射、豁免机制）

agent 在每一步应优先遵循 code-compass 的 skill 方法论（见 skills/ 下各 SKILL.md）。

## 项目 Wiki

项目文档位于 `docs/`，作为 AI agent 了解项目的入口：

- `docs/INDEX.md` —— **索引**，agent 应先读它再深入各文档
- `docs/overview.md` —— 项目概览（做什么、技术栈、快速开始、**下一步应运行 product-analysis**）
- `docs/architecture.md` —— 架构设计（分层、数据流、关键决策）
- `docs/modules.md` —— 核心模块（目录职责与边界）
- `docs/api.md` —— 功能清单及 API 接口文档

更新文档运行 `code-compass wiki`（重建索引）或 `code-compass wiki <overview|architecture|modules|api>`（重建指定文档）。
# <<< code-compass <<<
