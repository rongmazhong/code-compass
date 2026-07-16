---
name: qa
description: >
    自动化 QA 三连（qa / verify / review），按阶段推进状态机。用户说「跑 QA / 验证覆盖 / 代码评审 / 做代码审查」或活跃变更处于 implemented 及之后阶段时加载。
---

# qa / verify / review —— 状态机推进的 QA 自动化

本 skill 把"实现完成后的质量关"硬化为三个可机读的命令，分别对应
`implemented → verified → reviewed → summary` 的推进闸门。它们消费
`.harness/rules/workflow.md` 中的"测试 / 静态检查"命令与 `.harness/openspec/changes/<slug>/` 的 spec。

## 触发条件

- 用户加载 `qa` 子 skill（其散文会指示 agent 调 `bash scripts/qa.sh` / `bash scripts/verify.sh` / `bash scripts/review.sh`）
- 用户说"跑 QA"、"验证 spec 覆盖"、"做代码评审"
- 活跃变更处于 `implemented` 及之后阶段

## 前置

三个命令都针对**当前活跃变更**（`.harness/state/workflow-state.json` 的 `active`）。
无活跃变更时直接报错退出（exit 1），不推进状态。

---

### `qa` 子 skill 调 `bash scripts/qa.sh` —— 自动化 QA（implemented → verified）

1. 读取活跃变更。
2. 从 `.harness/rules/workflow.md` 解析"测试"与"静态检查"两条命令
   （`_wf_cmd` 按 `测试：<cmd>` / `静态检查：<cmd>` 行提取）。
   - 命令为占位（`（请补充）`/`（未识别）`）时给出黄色提醒并跳过该项。
   - **两项都无可用命令** → 警告不推进，提示先补全 `workflow.md`。
3. 在目标项目目录（`TARGET_DIR`）依次 `eval` 执行；任一非 0 → 警告"失败"、**不推进**。
4. 全部通过 → 阶段推进至 `verified`，打印 `✅ qa 通过`。

> 关键：qa 只认 `rules/workflow.md` 里真实配置的检查命令，不臆造；
> 命令缺失或失败时**硬停**，避免"假绿"推进。

### 前端 web 工程的浏览器端到端（agent-browser 集成）

`qa` **不新增任何 label**，完全复用 `rules/workflow.md` 里的"测试"命令。
当项目是**前端 web 工程**时，建议在"测试"命令中配置由 `agent-browser`
驱动的端到端脚本（或 `npx playwright test`），这样 `qa` 执行该命令时浏览器测试
自然被纳入，**无需改动 qa 机制本身**。

识别前端 web 工程的信号（命中其一即可）：
- 根目录含 `package.json` 且依赖含 `react` / `vue` / `svelte` / `next` / `vite` 等
- 存在 `index.html` / `vite.config.*` / `next.config.*`

引导做法（agent 在 web 项目时应建议用户配置）：
1. 在 `rules/workflow.md` 的"测试"行指向 e2e 脚本，例如：
   `- 测试：npx agent-browser run e2e/ 或 npx playwright test`
2. 保持"静态检查"行指向项目的 lint。
3. 运行 `bash scripts/qa.sh` —— 浏览器测试随"测试"命令一并执行。
4. 浏览器测试产出（截图/报告）由 e2e 工具落盘，agent 用 `gstack browse`
   类能力做视觉复核。

> 边界：code-compass 不内置浏览器、不引入外部依赖；浏览器测试是否执行
> 完全取决于"测试"命令的配置。未配置时 `qa` 行为与原来一致（仅跑既有测试/lint）。

### `qa` 子 skill 调 `bash scripts/verify.sh` —— spec 覆盖闸门（reviewed 前的可勾选校验）

1. 统计活跃变更 `specs/<cap>/spec.md` 中的 `### Requirement:` 条数。
2. 统计 `tasks.md` 中已勾选 `- [x]` 的条数。
3. 若 `需求数 > 已勾选数` → 警告"存在未覆盖需求 N 条"并退出非 0（**不推进**）。
4. 全覆盖 → 打印 `✅ 所有 Requirement 均有对应已勾选任务`。

> 这是 `verified → reviewed` 之间的覆盖闸门：先 `verify` 确认每条需求都落到勾选任务，再 `review`。

### `qa` 子 skill 调 `bash scripts/review.sh` —— 多视角审查链（reviewed 推进）

`review` 不再是静态清单，而是依次执行四个视角的可执行审查链：

1. 打印**代码变更统计**（`git diff --stat`）。
2. 列出 spec 的 `### Requirement:` 清单。
3. 依次执行四个视角：
   - **[product]** 逐条 `### Requirement:` 是否在 diff 中观察到对应实现
   - **[eng]** N+1 / 竞态 / 信任边界 / 错误处理降级（高置信模式）
   - **[security]** 硬编码密钥 / 注入 / 不安全反序列化 / 访问控制
   - **[design]** UI 一致性清单（仅清单，需人工确认）
4. 任一视角命中致命问题（❌/⚠️ 高置信）→ **不推进**并退出非 0。
5. 全部通过 → 阶段自动推进至 `reviewed`，打印 `✅ 多视角审查通过`。

> 模糊项标注"需人工确认"而非断言失败；design 视角永不阻断推进。
> 多视角脚本可独立运行：`bash scripts/review-product.sh` 等（仅该视角报告）。

---

## 与状态机的关系（见 `skills/status/SKILL.md`）

| 当前 stage | 推进命令 | 目标 stage |
|------------|----------|------------|
| `implemented` | 加载 `qa` 子 skill 调 `bash scripts/qa.sh` | `verified` |
| `verified` | 加载 `qa` 子 skill 调 `bash scripts/verify.sh`（覆盖闸门）+ `bash scripts/review.sh`（审查包） | `reviewed` |
| `reviewed` | 评审通过（summary 阶段总结） | `summary` |

- `qa` 失败或命令缺失：**硬停**，绝不带病推进。
- `verify` 未覆盖：**硬停**，倒逼补 tasks.md 勾选。
- `review` 只产出素材，推进权交给评审决策。
