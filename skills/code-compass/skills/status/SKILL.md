---
name: status
description: |
  查看 code-compass 工作流状态，或激活当前阶段的自动化流程。
  当用户运行 `code-compass status`、`code-compass status activate`、或说
  "查看当前状态 / 现在进行到哪一步了 / 继续自动化流程"时触发。
  复用 develop-workflow-rong 的**状态机思路**（已内置为自身逻辑，无需加载该 skill），支持断点续跑。
---

# status —— 查看状态与激活自动化

`code-compass status` 是工作流的"仪表盘 + 续跑开关"。它读取
`.harness/state/workflow-state.json`，显示当前阶段与进度，并可激活
下一步自动化动作（状态机思路参考 develop-workflow-rong，已内置，非依赖该 skill）。

## 触发条件

- 用户运行 `code-compass status`
- 用户运行 `code-compass status activate`（或 `--activate`）
- 用户问"现在进行到哪一步了"、"继续自动流程"、"恢复到哪了"

## 子命令

### `code-compass status`（默认）

读取状态文件并渲染：

- 当前阶段、关联 spec、当前分支、更新时间
- 完整阶段链进度（`✅` 已完成 / `🔵` 当前 / `⚪` 未开始）

阶段链以 `.harness/config.json` 的 `stages` 为准，默认：

```
idea → product-analysis → planned → dev → implemented → qa → verified → reviewed → summary
```

若项目未 `init`，提示先运行 `code-compass init`。

### `code-compass status activate`

在状态基础上，额外输出**当前阶段应执行的下一步自动化动作**，逻辑与
（状态机思路参考 develop-workflow-rong，已内置，非依赖该 skill）：

| 当前 stage | 激活动作（参考 develop-workflow-rong） |
|------------|----------------------------------------|
| `idea` | 运行 `product-analysis`，加载 skills/product-analysis/SKILL.md 柏拉图式发问 |
| `product-analysis` | 继续填充 `.harness/openspec/changes/<slug>/`，完成后推进 `planned` |
| `planned` | 运行 `dev`，进入 PLANNED→DEVELOPING 编排（writing-plans → TDD → 子代理） |
| `dev` | 加载 skills/dev/SKILL.md，按 计划→TDD→子代理→验证 推进到 `implemented` |
| `implemented` | IMPLEMENTED 阶段：agent-browser 端到端 QA，修复后推进 `qa` |
| `qa` | QA_PASSED 阶段：测试 + lint + 类型检查，推进 `verified` |
| `verified` | VERIFIED 阶段：requesting-code-review，推进 `reviewed` |
| `reviewed` | REVIEWED 阶段：review + codex 跨模型二审，推进 `summary` |
| `summary` | SUMMARY 阶段：总结文档并更新状态 |

## 断点续跑

每个阶段执行完毕后，对应 skill 将 `stage` 写入 `workflow-state.json`。
下次运行 `code-compass status activate`，即从当前 `stage` 自动续跑，无需手动路由。

若需回退，手动编辑 `stage` 字段到目标阶段即可。
