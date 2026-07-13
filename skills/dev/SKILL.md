---
name: dev
description: |
  基于 OpenSpec 的 spec 文档进行开发实现。当用户运行 `code-compass dev [name]`、
  或说"开始实现 / 按 spec 开发 / 进入开发阶段"时触发。借鉴 superpowers / develop-workflow-rong 的方法论：
  writing-plans / TDD / subagent-driven-development 与 develop-workflow-rong 的状态机编排；均为可选增强，已内化为自包含指引，非强制依赖。
---

# dev / develop —— 基于 spec 的开发实现

消费 `.harness/openspec/changes/<slug>/` 中的 spec，按"计划 → TDD → 子代理实现 → 验证"
的闭环完成开发，并维护 `.harness/state/workflow-state.json` 阶段推进。

## 触发条件

- 用户运行 `code-compass dev [name]` 或 `code-compass develop [name]`
- 用户说"开始实现"、"按 spec 开发"
- `.harness/state/workflow-state.json` 的 `stage` 为 `planned` 或 `product-analysis`

## 阶段前置

CLI 已将 `stage` 置为 `dev`，并选定 `.harness/openspec/changes/<slug>/`。
**关键：CLI 已自动创建（或复用）本次变更的 git worktree**，输出中给出：
- worktree 路径（如 `<父目录>/worktrees/<slug>`）
- 分支名（如 `feat/<slug>`）

## 执行流程

### 0. WORKTREE —— 切换到隔离工作区
- `cd` 到 CLI 输出的 worktree 路径，后续所有开发均在该 worktree 内进行，
  主仓库保持干净、互不影响。
- 若目标项目不是 git 仓库，CLI 会回退到当前目录直接开发。
- spec 文件仍在主仓库 `.harness/openspec/changes/<slug>/`，agent 按该绝对路径读取。
- 开发完成、分支合并/删除前，运行 `code-compass worktree prune` 清理注册信息。

### 1. PLANNED —— 计划拆解（writing-plans）
- 读取 `specs/<capability>/spec.md` 的 Requirements
- 将每条 Requirement 拆成可独立验证的微任务，回填到 `tasks.md`
- 标注依赖关系与顺序（拓扑排序）

### 2. DEVELOPING —— TDD 实现（test-driven-development + subagent）
- 为每个任务建立"红-绿-重构"循环：
  1. 先写失败的测试（红）
  2. 写最小实现使其通过（绿）
  3. 重构并保持测试通过
- 可用 `subagent-driven-development`：把无依赖的任务分派给并行子代理
- 每完成一个任务，更新 `tasks.md` 勾选状态

### 3. IMPLEMENTED → QA（agent-browser / 系统测试）
- 运行测试套件与 lint / 类型检查
- 若为 Web 应用，用 `agent-browser` 做端到端流程验证并截图留证
- 发现的问题定位根因后修复（systematic-debugging）

### 4. VERIFIED —— 完成前验证（verification-before-completion）
- 确认所有 `tasks.md` 勾选、测试全绿、spec 的 Requirement 全部覆盖
- 更新 `workflow-state.json`：`stage` 推进到 `implemented` → `qa` → `verified`

### 5. REVIEWED —— 代码审查（可选衔接 gstack）
- 调用 `requesting-code-review` / gstack 的 `review` + `codex` 二审
- 通过后 `stage` 进入 `reviewed`，可衔接 `/ship` 发布流水线

## workflow-state 阶段链

```
idea → product-analysis → planned → dev → implemented → qa → verified → reviewed → summary
```

每次阶段切换都必须更新 `.harness/state/workflow-state.json`，保证中断后可从断点续跑。

## 与方法的对应

> 以下为方法论**灵感来源**（可选增强，非强制依赖），均已内化为本 skill 的自包含指引。

- **superpowers**：writing-plans / TDD / subagent-driven-development / systematic-debugging / verification-before-completion
- **gstack**：QA 用 agent-browser；审查用 review + codex；发布用 /ship
- **openspec**：实现严格对齐 `changes/<slug>/specs` 的 Requirement
- **develop-workflow-rong**：状态机阶段即本 skill 的推进依据
