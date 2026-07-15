# Spec: stage-tracks

> OpenSpec 风格的能力 spec（delta）。描述目标状态，每条 Requirement 须可验证。

## ADDED Requirements

### Requirement: tracks 映射配置

系统 SHALL 在 `.harness/config.json` 提供 `tracks` 映射，键为 tier（research/small/standard/standard+/refactor），值为该 track 对应的**有序阶段数组**（子集/重排自 `stages`）。当 `tracks` 缺失或某 tier 未定义时，SHALL 回退到完整 `stages` 链，不得因此中断 CLI。

#### Scenario: tracks 完整定义

- **WHEN** `config.json` 含合法的 `tracks.research/small/standard/standard+/refactor`
- **THEN** 各 tier 返回其声明的阶段数组

#### Scenario: tracks 缺失回退

- **WHEN** `config.json` 无 `tracks` 字段
- **THEN** 所有 tier 回退到 `stages` 完整链，命令不中断

### Requirement: product-analysis 选定并写入 track

系统 SHALL 在 `product-analysis` 流程结尾（步骤 5 设计确认后）将选定 tier 对应的 track 名写入 `.harness/state/workflow-state.json` 的 `track` 字段，缺省为 `standard`。当 `track` 字段缺失时状态读取 SHALL 以 `standard` 兜底。

#### Scenario: 写入 track

- **WHEN** 用户在设计确认时选定 tier 为"小特性"
- **THEN** `workflow-state.json` 的 `track` 写入 `small`

#### Scenario: track 缺失兜底

- **WHEN** 状态文件无 `track` 字段
- **THEN** 读取时以 `standard` 处理，不抛异常

### Requirement: status 按 track 渲染阶段链

系统 SHALL 在 `code-compass status` 渲染阶段链时，依据 `workflow-state.json` 的 `track` 选取对应阶段数组渲染进度，而非固定 `stages` 全链。

#### Scenario: 小特性链不含 reviewed

- **WHEN** `track=small` 且当前阶段为 `qa`
- **THEN** 渲染的阶段链为 `idea→product-analysis→planned→dev→implemented→qa→verified→summary`，不含 `reviewed`

#### Scenario: research 链精简

- **WHEN** `track=research`
- **THEN** 渲染链仅含 `idea→product-analysis→planned→dev→summary`

### Requirement: guard 按 track 校验阶段合法性

系统 SHALL 在 `guard`/`commit` 闸门校验时，依据当前 `track` 的阶段集合判断"是否偏离"。对当前 track 已裁剪掉的阶段，SHALL 不将其视为合法目标，且当阶段处于 idea/product-analysis 时对**当前 track 合法**的 spec 缺失才拦截。

#### Scenario: 小特性跳过 reviewed 不报错

- **WHEN** `track=small`，`stage=verified`，spec 已存在
- **THEN** `guard` 以 0 退出，不提示"缺少 reviewed 阶段"类偏离

#### Scenario: idea 阶段仍拦截

- **WHEN** `track=small`，`stage=idea`，无 spec
- **THEN** `guard` 非 0 退出并提示先走 product-analysis
