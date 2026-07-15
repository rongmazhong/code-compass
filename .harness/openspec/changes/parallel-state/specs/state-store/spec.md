# Spec: state-store

> OpenSpec 风格的能力 spec（delta）。描述目标状态，每条 Requirement 须可验证。

## ADDED Requirements

### Requirement: 内嵌多对象状态 schema

系统 SHALL 将 `.harness/state/workflow-state.json` 重构为内嵌多对象结构：`{"active": "<slug>", "changes": {"<slug>": {"stage": "...", "branch": "...", "track": "...", "vapd_id": "...", "updated_at": "...", "completed": [...]}}}}`。当 `changes` 为空或 `active` 缺失时，相关读取 SHALL 以空值/默认兜底，不得中断。

#### Scenario: 合法多对象结构

- **WHEN** 状态文件含 `active` 与 `changes` 且有多条变更
- **THEN** 各变更的阶段独立读取，互不覆盖

#### Scenario: 字段缺失兜底

- **WHEN** 某变更的 `branch` 或 `track` 缺失
- **THEN** 以空字符串兜底，脚本不中断

### Requirement: 状态写入按活跃变更隔离

系统 SHALL 在 `_set_stage` 等写入操作时，将阶段/分支/时间写入 `changes[active]` 对应条目，而非顶层单点字段；写入前若 `active` 无对应 `changes` 条目则自动创建。

#### Scenario: 写入隔离

- **WHEN** `active=foo` 时执行阶段推进到 `dev`
- **THEN** 仅 `changes.foo.stage` 更新为 `dev`，`changes.bar` 不受影响

### Requirement: status 作用于 active 且支持 --all

系统 SHALL 在 `code-compass status`（无 `--all`）时渲染 `active` 对应变更的阶段链；`code-compass status --all` SHALL 列出全部变更 slug 及其当前阶段。

#### Scenario: 默认渲染 active

- **WHEN** `active=foo`
- **THEN** `status` 仅展示 foo 的阶段链

#### Scenario: --all 列出全部

- **WHEN** `changes` 含 foo 与 bar
- **THEN** `status --all` 输出 foo 与 bar 各自阶段

### Requirement: 旧扁平 schema 兼容迁移

系统 SHALL 在读取时识别旧的扁平结构（`stage`/`spec`/`branch` 直接置于顶层且无 `changes`），自动将其迁移为 `changes[<spec>]` 并设 `active=<spec>`，迁移后写回；无法判定 spec 时 SHALL 以 `active` 为空并保留原数据，不静默丢失。

#### Scenario: 读取旧 schema 自动迁移

- **WHEN** 读取到顶层含 `stage` 且无 `changes` 的文件
- **THEN** 转换为 `changes[<spec>]` 结构并写回，原有阶段保留

#### Scenario: 缺失 spec 不静默丢失

- **WHEN** 旧文件顶层无 `spec` 且无法推断
- **THEN** 保留原数据、`active` 置空并给出提示，不删除原内容
