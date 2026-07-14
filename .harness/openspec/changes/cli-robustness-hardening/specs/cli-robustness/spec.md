# Spec: cli-robustness

> OpenSpec 风格的能力 spec（delta）。描述目标状态，每条 Requirement 须可验证。
> 所有改动集中在 `skills/code-compass/code-compass`。

## ADDED Requirements

### Requirement: JSON 读写去 Python 化

系统 SHALL 提供统一的 `_json_get <file> <field>` 与 `_json_set <file> <json-patch-or-fields>` 抽象，优先使用 `jq`，在无 `jq` 时回退纯 bash 解析（仅支持本项目固定 schema 的扁平字段），从而彻底移除对 `python3` 的硬依赖；当 `jq` 与 `python3` 均不可用时，相关命令 SHALL 给出明确降级提示而非静默失败。

#### Scenario: 环境具备 jq

- **WHEN** 系统存在 `jq` 可执行文件
- **THEN** 所有状态读写经由 `jq` 完成，行为与原有 python 实现等价

#### Scenario: 环境无 jq 且无 python3

- **WHEN** `command -v jq` 与 `command -v python3` 均失败
- **THEN** 状态读写相关函数输出可操作的降级提示，不再以 `die "未找到 python3"` 直接终止整个 CLI

### Requirement: 闸门豁免环境变量生效

系统 SHALL 在 `guard` / `commit` / `dev` 的闸门校验分支开头读取环境变量 `CODE_COMPASS_GUARD`，当其值为 `off` 时跳过全部阶段拦截并以 0 退出。

#### Scenario: 设置 CODE_COMPASS_GUARD=off 时绕过闸门

- **WHEN** 用户执行 `CODE_COMPASS_GUARD=off code-compass guard`（且当前阶段为 `idea`）
- **THEN** 命令以 0 退出且不输出拦截警告

#### Scenario: 未设置或值非 off 时维持原行为

- **WHEN** 未设置该变量且阶段为 `idea`
- **THEN** 维持原有拦截逻辑（exit 非 0 + 警告）

### Requirement: status 健壮解析状态

系统 SHALL 对 `workflow-state.json` 做一次解析，对每个缺失字段以空字符串兜底，不得为每个字段单独派生 python / jq 子进程，且字段缺失时不得因解析异常中断脚本。

#### Scenario: 字段完整

- **WHEN** 状态文件含 `stage` / `spec` / `branch` / `updated_at`
- **THEN** `code-compass status` 正常渲染阶段链与字段

#### Scenario: 字段缺失

- **WHEN** 状态文件缺少 `branch` 或 `updated_at` 等可选字段
- **THEN** 该字段以"（未知/无）"显示，脚本不中断、不抛未捕获异常

### Requirement: 区分未初始化与状态文件损坏

系统 SHALL 在读取状态时区分三种情况：文件不存在（未初始化，`_can_code` 返回 2）、文件存在但 JSON 不合法（损坏，明确报错并提示如何修复）、文件合法但阶段不符（拦截）。不得把"损坏"误判为"阶段偏离"而给出含糊的偏离提示。

#### Scenario: 状态文件不存在

- **WHEN** `.harness/state/workflow-state.json` 不存在
- **THEN** `guard` 提示"项目尚未 init"并以 1 退出，不误报阶段偏离

#### Scenario: 状态文件为非法 JSON

- **WHEN** 状态文件存在但内容非法 JSON
- **THEN** 命令输出明确的"状态文件损坏"错误及修复建议，而非含糊的"闸门拦截：阶段偏离"

### Requirement: product-analysis 默认 spec 落点

系统 SHALL 在 `product-analysis` 创建变更工作区时，将 spec 模板落到具名默认 capability（如 `specs/core/spec.md`），不再遗留字面量 `<capability>` 占位目录；`dev` 阶段的 spec 存在性校验 SHALL 基于真实命名目录。

#### Scenario: 正常创建

- **WHEN** 运行 `code-compass product-analysis <name>`
- **THEN** 生成 `changes/<slug>/specs/core/spec.md`，不存在 `specs/<capability>/` 字面量目录

#### Scenario: dev 校验

- **WHEN** `dev` 检查 spec 存在性时
- **THEN** 仅匹配真实 capability 目录，不因字面量占位目录而产生"假 spec 通过"

### Requirement: worktree 路径内聚

系统 SHALL 将开发用 git worktree 创建于 `TARGET_DIR/.worktrees/<slug>`（并自动追加到 `.gitignore`），而非置于 `TARGET_DIR` 的父目录，避免 agent 需 `cd` 出项目且路径随 slug 嵌套变深。

#### Scenario: git 仓库正常创建

- **WHEN** 目标项目为 git 仓库且运行 `dev <slug>`
- **THEN** worktree 位于 `<TARGET_DIR>/.worktrees/<slug>`，分支 `feat/<slug>`，且 `.worktrees/` 已加入 `.gitignore`

#### Scenario: 非 git 仓库回退

- **WHEN** 目标项目不是 git 仓库
- **THEN** 回退到 `TARGET_DIR` 直接开发（保持既有行为）

### Requirement: 状态文件原子写入

系统 SHALL 在更新 `workflow-state.json` 时先写入临时文件再 `mv` 原子替换，防止并发 / 中断导致 JSON 写坏、后续所有命令瘫痪。

#### Scenario: 写入中断安全

- **WHEN** `_set_stage` / `_set_vapd` 执行写入
- **THEN** 写入过程为临时文件 + 原子 `mv`，不会出现半截 JSON 被其他进程读到
