---
name: status
description: >
    查看工作流阶段进度、激活续跑，或做阶段闸门校验（guard）。用户说「现在到哪 / 能否动手 / 继续流程 / 查看进度」或需续跑 / 闸门自检时加载。
---

# status —— 查看状态、激活自动化与阶段闸门

`bash scripts/status.sh` 是工作流的"仪表盘 + 续跑开关"。它读取
`.harness/state/workflow-state.json`，显示当前阶段与进度，并可激活
下一步自动化动作（状态机思路参考 develop-workflow-rong，已内置，非依赖该 skill）。

`bash scripts/guard.sh`（或 `bash scripts/status.sh --guard`）的阶段闸门逻辑见 `skills/guard/SKILL.md`。

## 触发条件

- 用户加载 `status` 子 skill（agent 调 `bash scripts/status.sh`）
- 用户加载 `status` 子 skill 并激活（或 `bash scripts/status.sh activate`）
- 用户加载 `guard` 子 skill（或 `bash scripts/status.sh --guard`）
- 用户问"现在进行到哪一步了"、"继续自动流程"、"恢复到哪了"、"现在能动手了吗"

## 子命令

### `bash scripts/status.sh`（默认）

读取状态文件并渲染：

- 当前阶段、关联 spec、当前分支、更新时间
- 完整阶段链进度（`✅` 已完成 / `🔵` 当前 / `⚪` 未开始）

阶段链以 `.harness/config.json` 的 `stages` 为准（默认见主 `SKILL.md` 与 `AGENTS.md.harness`）。

若项目未 `init`，提示先加载 `init` 子 skill。

### `bash scripts/status.sh activate`

在状态基础上，额外输出**当前阶段应执行的下一步自动化动作**，逻辑与
（状态机思路参考 develop-workflow-rong，已内置，非依赖该 skill）：

| 当前 stage | 激活动作（参考 develop-workflow-rong） |
|------------|----------------------------------------|
| `idea` | 加载 `product-analysis` 子 skill，柏拉图式发问 |
| `product-analysis` | 继续填充 `.harness/openspec/changes/<slug>/`，完成后推进 `planned` |
| `planned` | 加载 `dev` 子 skill，进入 PLANNED→DEVELOPING 编排（writing-plans → TDD → 子代理） |
| `dev` | 加载 `dev` 子 skill，按 计划→TDD→子代理→验证 推进到 `implemented` |
| `implemented` | IMPLEMENTED 阶段：agent-browser 端到端 QA，修复后推进 `qa` |
| `qa` | QA_PASSED 阶段：测试 + lint + 类型检查，推进 `verified` |
| `verified` | VERIFIED 阶段：requesting-code-review，推进 `reviewed` |
| `reviewed` | REVIEWED 阶段：review + codex 跨模型二审，推进 `summary` |
| `summary` | SUMMARY 阶段：总结文档并更新状态 |

## 断点续跑

每个阶段执行完毕后，对应 skill 将 `stage` 写入 `workflow-state.json`。
下次加载 `status` 子 skill 并激活（或运行 `bash scripts/status.sh activate`），即从当前 `stage` 自动续跑，无需手动路由。

若需回退，手动编辑 `stage` 字段到目标阶段即可。

## 阶段闸门（guard）

`bash scripts/guard.sh` 的独立方法论见 `skills/guard/SKILL.md`（闸门逻辑、豁免机制同该 skill）。
`status` 在阶段为 `idea` / `product-analysis` 时也会附上偏离提醒，引导先走 `product-analysis`。
