# Change: qa-automation

## Why

> `implemented→qa→verified→reviewed` 四个阶段在 CLI 层无任何自动化命令支撑，阶段推进完全依赖 agent 手动改写 `workflow-state.json`。同时 `rules/workflow.md` 已定义构建/测试/lint 命令字段（虽本项目为占位），但没有任何命令去消费它。结果：后半段阶段链是"空壳"，方法论权威性弱。

- 问题本质：阶段链后半段缺 CLI 自动化；测试命令源（`rules/workflow.md`）未被消费。
- 用户对象：执行 qa/verify/review 的 AI agent。
- 范围边界（MVP 必含）：`qa`（消费 workflow.md 跑测试并推进）、`verify`（tasks↔spec 覆盖度）、`review`（生成审查包）。
- 非目标：CLI 不直接 spawn 跨模型子代理（`reviewed` 的二审由 agent 执行）；不重写 workflow.md 探测。
- 成功信号：跑通 `code-compass qa` 后 stage 自动到 `verified`；`code-compass verify` 能列出未覆盖的 spec Requirement。

## What Changes

> 触及能力：qa-automation（后半段阶段自动化命令）。

## Impact

> 影响范围：`skills/code-compass/code-compass` 新增 `qa`/`verify`/`review` 子命令；读取 `.harness/rules/workflow.md` 的测试/lint 字段。

## Dependencies / Ordering

> 依赖 `parallel-state` 的状态抽象（写入 stage 经 `changes[active]`）；依赖 `sop-tiers` 的 track 以确定 qa 是否强制回归（refactor track）。建议 parallel-state 先落地。
