---
name: dev
description: >
    基于 spec 的开发实现（自动 worktree 隔离、TDD、子代理）。用户说「开始实现 / 按 spec 开发 / 进入开发」或按本库方法论、已有 spec 要落地时加载。
---

# dev / develop —— 基于 spec 的开发实现

消费 `.harness/openspec/changes/<slug>/` 中的 spec，按"计划 → TDD → 子代理实现 → 验证"
的闭环完成开发，并维护 `.harness/state/workflow-state.json` 阶段推进。

## 触发条件

- 用户加载 `dev` 子 skill（开头调 `bash scripts/guard.sh` 再 `bash scripts/worktree.sh`）
- 用户说"开始实现"、"按 spec 开发"
- `.harness/state/workflow-state.json` 的 `stage` 为 `planned` 或 `product-analysis`

## 阶段前置

脚手架已将 `stage` 置为 `dev`，并选定 `.harness/openspec/changes/<slug>/`。
**关键：脚手架已自动创建（或复用）本次变更的 git worktree**，输出中给出：
- worktree 路径（如 `<父目录>/worktrees/<slug>`）
- 分支名（如 `feat/<slug>`）

### 进入闸门（强制）

`dev` 在动手前校验阶段：若 `.harness/state/workflow-state.json` 的 `stage` 仍处
`idea` / `product-analysis`（尚未生成已确认 spec），**直接拦截**并提示先加载
`product-analysis` 子 skill。这是把"先分析后开发"硬化为硬约束的核心拦截点。

- 豁免：`bash scripts/dev.sh --force <slug>` 强制进入（并会在回复中说明豁免理由）；
  若变更工作区尚不存在，`--force` 会自动脚手架 proposal/tasks/spec 模板。
- 仍建议：`dev` 仅在所有 Requirement 已落 spec、阶段达 `planned` 后调用。

## 执行流程

### 0. WORKTREE —— 切换到隔离工作区
- `cd` 到脚手架输出的 worktree 路径，后续所有开发均在该 worktree 内进行，
   主仓库保持干净、互不影响。
- 若目标项目不是 git 仓库，脚手架会回退到当前目录直接开发。
- spec 文件仍在主仓库 `.harness/openspec/changes/<slug>/`，agent 按该绝对路径读取。
- 开发完成、分支合并/删除前，运行 `bash scripts/worktree.sh prune` 清理注册信息。

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

### 2.1 提交规范（git commit 必须遵循）
- 统一用 **`bash scripts/commit.sh <type> <描述...>`** 提交（自动拼接 vapd_id，不要手写 `git commit -m`）。
- 格式与 VAPD 标识规则见 `skills/commit/SKILL.md`；示例：`feat: #VR12345#开发登录接口`。

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

阶段链与每次切换的持久化规则见主 `SKILL.md`（或 `.harness/state/workflow-state.json` 注释）：
`idea → product-analysis → planned → dev → implemented → qa → verified → reviewed → summary`。
每次阶段切换都必须更新 `workflow-state.json`，保证中断后可从断点续跑。
