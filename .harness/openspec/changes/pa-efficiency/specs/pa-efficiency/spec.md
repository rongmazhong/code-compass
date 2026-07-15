# Spec: pa-efficiency

> OpenSpec 风格的能力 spec（delta）。描述目标状态，每条 Requirement 须可验证。

## ADDED Requirements

### Requirement: 澄清提问按 tier 弹性上限

系统 SHALL 在 `product-analysis` 步骤 3 依据 tier 设定每轮澄清提问的数量上限：小特性/研究型每轮最多 3 个**相关**问题；中特性/大特性/重构每轮最多 2 个问题。仍须满足停止条件（需求清晰、边界明确、非目标清楚、成功信号可观测）方可进入步骤 4，不因放宽而跳过澄清。

#### Scenario: 小特性多问

- **WHEN** tier 为小特性，存在 3 个独立澄清点
- **THEN** 允许单轮抛出至多 3 个相关问题，而非强制 3 轮

#### Scenario: 大特性每轮上限 2

- **WHEN** tier 为大特性
- **THEN** 每轮提问不超过 2 个，仍保持逐步收敛

### Requirement: 清晰描述/PRD 快速通道

系统 SHALL 在 product-analysis 触发时，若用户已提供清晰的需求描述或附带 PRD/设计文档，允许跳过步骤 3 的澄清轮次，直接进入步骤 4（对抗验证 + 提出方案）。快速通道仍须执行步骤 2 并行探索与步骤 4 对抗验证，不得跳过。

#### Scenario: 附带 PRD 跳澄清

- **WHEN** 用户触发时给出结构化 PRD 且关键不确定点已在文档中回答
- **THEN** 跳过步骤 3，直接进入步骤 4

#### Scenario: 描述仍模糊不走快速通道

- **WHEN** 用户仅给出模糊一句意图
- **THEN** 仍需执行步骤 3 澄清，不进入快速通道
