---
name: code-compass
description: >
   code-compass 总入口：spec 驱动、状态机编排、先分析后开发的强制约束方法论库。用户要启用本库、按本库方法论工作、或触发任一子能力（init / product-analysis / dev / guard 等）时加载。
---

# code-compass

个人 skill 库，提供一套 spec 驱动、状态机编排的开发方法论。
**方法论是默认硬约束**：动手写代码前必须先经 `product-analysis` 生成已确认 spec，
`guard` 子 skill 会在阶段不符时拦截偏离。

## 安装与启用

本 skill 通过 skills 注册表分发。安装后把本仓库放进 agent 的 skills 目录即可用，无需配置 shell 或 python3：

```bash
npx skills add rongmazhong/code-compass
```

安装后加载 `using-code-compass` 子 skill 完成当前项目初始化（其散文会指示 agent 调 `bash scripts/use.sh`）。

## 意图 → 子 skill

agent 按用户意图直接加载对应子 `SKILL.md`（需要机械操作时由子 skill 散文指示调 `scripts/*.sh`）：

| 用户意图 | 子 skill | 机械操作 |
|----------|----------|----------|
| 启用库 / 接入项目 / 初始化 | `using-code-compass` | `bash scripts/use.sh` |
| 初始化 `.harness/` 运行基座 | `init` | `bash scripts/init-harness.sh` |
| 新功能 / 需求分析 / 出方案 | `product-analysis` | `bash scripts/product-analysis.sh` |
| 按 spec 开发 / 进入开发 | `dev` | 开头 `bash scripts/guard.sh` + `bash scripts/worktree.sh` |
| 管理 git worktree | `worktree` | `bash scripts/worktree.sh` |
| 记录/查看 VAPD 标识 | `vapd` | `bash scripts/vapd.sh` |
| 按规范提交 | `commit` | `bash scripts/commit.sh` |
| 查看状态 / 激活续跑 / 闸门 | `status` | `bash scripts/status.sh` |
| 阶段闸门校验 | `guard` | `bash scripts/guard.sh` |
| 更新项目 wiki | `wiki` | `bash scripts/wiki.sh` |
| 跑 QA / 验证覆盖 / 代码评审 | `qa` | `bash scripts/qa.sh` / `verify.sh` / `review.sh` |
| 刷新 harness 配置 | `upgrade` | `bash scripts/upgrade.sh` |

## 使用方式

方法论是**默认硬约束**：任何代码改动意图，先走 `product-analysis → planned → dev` 阶段机，
未生成 spec 不得直接编码。agent 加载本 skill 后，依据用户意图加载对应子 skill：
- 新建/接入项目 → 加载 `init` 子 skill（注入强制约束、引导补全 overview、生成 rules/guard.md）
- 需求不明确 / 用户说"新功能、做客户端、实现 X" → 加载 `product-analysis` 子 skill（柏拉图式发问；`--track` 选档位、`--append` 抽离澄清、`--force` 省交互）
- 动手前闸门校验 → 加载 `guard` 子 skill（偏离会拦截，exit 非 0）
- 已有 spec 要落地 → 加载 `dev` 子 skill（阶段未到 planned 会被拦截，可用 `bash scripts/dev.sh --force` 豁免）
- 实现完成后的质量关 → 加载 `qa` 子 skill（跑测试/静态检查→verified）→ verify（spec 覆盖闸门）→ review（审查包）

每个子能力的详细方法论见 `skills/<name>/SKILL.md`。阶段进度统一维护在
`.harness/state/workflow-state.json`，阶段链：
`idea → product-analysis → planned → dev → implemented → qa → verified → reviewed → summary`。

## 设计融合

> 以下为方法论**灵感来源**（可选增强，非强制依赖）：code-compass 已将其内化为自包含的 skill 工作流，单独使用即可跑通全流程。

- **superpowers**：方法论优先（先理解再实现、TDD、系统化调试、验证）
- **gstack**：QA 用 agent-browser，审查用 review + codex，发布用 /ship
- **OpenSpec**：`.harness/openspec/changes/<slug>/` 的 proposal + tasks + spec delta
- **develop-workflow-rong**：状态机阶段即编排依据，支持断点续跑
