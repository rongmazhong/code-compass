# Spec: quality-gates

> OpenSpec 风格的能力 spec（delta）。描述目标状态，每条 Requirement 须可验证。

## ADDED Requirements

### Requirement: review-multi-perspective

系统 SHALL 将 `cmd_review` 从静态清单升级为依次执行 product/eng/security/design 四个视角的可执行审查链，并汇总结构化报告。

#### Scenario: 正常路径（四视角执行）

- **WHEN** 运行 `bash scripts/review.sh` 且存在活跃变更与 spec
- **THEN** 依次输出 product（SHALL 对齐）、eng（N+1/竞态/信任边界/降级）、security（硬编码密钥/注入/反序列化/访问控制）、design（UI 一致性清单）四个视角的检查结果，并汇总为单一审查报告

#### Scenario: 边界 / 异常路径（无 spec）

- **WHEN** 运行 `bash scripts/review.sh` 但变更工作区无 specs/*/spec.md
- **THEN** 系统警告"未找到 spec"，仍执行 eng/security/design 视角但 product 视角标注跳过，不中断流程

### Requirement: review-stage-advance

系统 SHALL 在 `cmd_review` 成功生成审查报告后将活跃变更的阶段推进至 `reviewed`。

#### Scenario: 正常路径（阶段推进）

- **WHEN** `cmd_review` 完成四视角审查且无致命错误
- **THEN** `.harness/state/workflow-state.json` 中该变更的 stage 被置为 `reviewed`

#### Scenario: 边界 / 异常路径（致命问题）

- **WHEN** 任一视角检出致命问题（如 security 命中硬编码密钥高置信模式）
- **THEN** 报告标注失败，阶段不推进，退出码非 0

### Requirement: verify-multi-dimensional

系统 SHALL 将 `cmd_verify` 从单维度（Requirement 数 vs tasks 勾选数）增强为四维结构化验证：spec 覆盖、测试状态、文档同步、提交规范。

#### Scenario: 正常路径（四维全绿）

- **WHEN** 运行 `bash scripts/verify.sh` 且 spec 覆盖映射完整、测试全绿、docs 与代码同步、提交均带 VAPD
- **THEN** 输出四维结构化报告，每维标记通过，退出码 0

#### Scenario: 边界 / 异常路径（维度缺失）

- **WHEN** tasks.md 中某 Requirement 无对应 test 映射行，或分支存在未带 VAPD 的提交
- **THEN** 该维标记失败并列出具体项，退出码非 0

### Requirement: verify-spec-coverage-mapping

系统 SHALL 通过解析 `tasks.md` 中的 `Requirement → test` 映射行，弱校验每条 Requirement 是否有关联测试。

#### Scenario: 正常路径（映射存在）

- **WHEN** tasks.md 含形如 `- Requirement: <name> → test: <path>` 的行且对应测试文件存在
- **THEN** 该 Requirement 标记为已覆盖

#### Scenario: 边界 / 异常路径（映射缺失或测试不存在）

- **WHEN** 某 Requirement 无映射行，或映射的测试文件不存在
- **THEN** 该 Requirement 标记为未覆盖并列出

### Requirement: qa-web-browser-integration

系统 SHALL 在不新增 workflow.md label 的前提下，使 `cmd_qa` 能在前端 web 工程配置 agent-browser 测试命令时执行浏览器端到端测试，未配置时跳过保持原行为。

#### Scenario: 正常路径（web 工程已配置）

- **WHEN** 项目为前端 web 工程且 `rules/workflow.md` 的"测试"命令指向 agent-browser/playwright 等浏览器测试
- **THEN** `cmd_qa` 执行该"测试"命令，浏览器测试纳入 QA

#### Scenario: 边界 / 异常路径（未配置浏览器测试）

- **WHEN** "测试"命令不含浏览器语义，或项目非 web 工程
- **THEN** `cmd_qa` 按原逻辑执行既有测试/lint，不报错、不新增 label

### Requirement: qa-skill-web-guidance

系统 SHALL 在 `skills/qa/SKILL.md` 中增加引导：当识别为前端 web 工程时，建议用户在 `rules/workflow.md` 的"测试"命令中配置 agent-browser 驱动的 e2e 脚本。

#### Scenario: 正常路径（引导存在）

- **WHEN** agent 加载 qa 子 skill 且项目含前端框架迹象（package.json 含前端依赖 / index.html / vite 等）
- **THEN** SKILL.md 散文提示配置 agent-browser e2e 命令，并说明 qa 复用现有"测试" label 执行
