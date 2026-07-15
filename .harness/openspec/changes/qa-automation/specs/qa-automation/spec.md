# Spec: qa-automation

> OpenSpec 风格的能力 spec（delta）。描述目标状态，每条 Requirement 须可验证。

## ADDED Requirements

### Requirement: qa 命令消费 workflow.md 并推进

系统 SHALL 提供 `code-compass qa`，解析 `.harness/rules/workflow.md` 中的测试/静态检查命令并执行；全部通过时自动将当前变更 stage 推进至 `verified`；任一命令失败则不以 0 退出且不推进阶段，并输出失败摘要。

#### Scenario: 测试通过自动推进

- **WHEN** `rules/workflow.md` 的测试/lint 命令均成功退出
- **THEN** stage 推进至 `verified`，命令以 0 退出

#### Scenario: 测试失败不推进

- **WHEN** 任一命令非 0 退出
- **THEN** 命令非 0 退出，stage 保持 `qa`，输出失败项

### Requirement: verify 命令比对覆盖度

系统 SHALL 提供 `code-compass verify`，读取当前变更 `specs/*/spec.md` 的 `### Requirement:` 条目与 `tasks.md` 的勾选状态，输出未勾选/无对应任务的需求清单；全部覆盖时以 0 退出。

#### Scenario: 存在未覆盖需求

- **WHEN** spec 有 3 条 Requirement 但 tasks.md 仅勾选 2 条
- **THEN** 输出未覆盖的 1 条 Requirement 名，命令非 0 退出

#### Scenario: 全部覆盖

- **WHEN** 所有 Requirement 均有对应已勾选任务
- **THEN** 以 0 退出

### Requirement: review 命令生成审查包

系统 SHALL 提供 `code-compass review`，聚合当前变更的 diff 统计、spec 摘要与审查清单，输出供 agent 执行二审的"审查包"；不尝试直接 spawn 外部子代理，环境无可用审查器时 SHALL 仅输出清单并以 0 退出。

#### Scenario: 生成审查包

- **WHEN** 运行 `code-compass review`
- **THEN** 输出含 diff stat、spec 条目清单、审查 checklist 的文本

#### Scenario: 无外部审查器不报错

- **WHEN** 环境未检测到 codex/claude 等审查 CLI
- **THEN** 仅输出清单并以 0 退出，不报错中断
