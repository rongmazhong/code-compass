# Spec: using-code-compass

> OpenSpec 风格的能力 spec（delta）。描述目标状态，每条 Requirement 须可验证。

## ADDED Requirements

### Requirement: 未初始化项目自动 init

当目标项目不存在 `.harness/` 目录时，`using-code-compass` SHALL 自动执行 `init` 流程，
生成 state/rules/openspec/docs 并在 AGENTS.md 注入路由段；已存在 `.harness/` 时 SHALL 跳过。

#### Scenario: 项目未 init

- **WHEN** 运行 `code-compass using-code-compass` 且 `$TARGET_DIR/.harness` 不存在
- **THEN** 自动执行 init，输出中含"目标项目尚未初始化，先执行 init"，并最终生成 `.harness/` 与状态卡

#### Scenario: 项目已 init

- **WHEN** 运行 `code-compass using-code-compass` 且 `$TARGET_DIR/.harness` 已存在
- **THEN** 跳过 init，输出"目标项目已初始化"，直接打印状态卡

### Requirement: 内联报告项目状态卡

`using-code-compass` SHALL 在执行末尾内联打印状态卡，包含 stage / 关联 spec / 开发分支 /
VAPD 标识 / 最近更新，并依据当前 stage 推导"下一步"建议。

#### Scenario: 输出状态卡

- **WHEN** 运行 `code-compass using-code-compass`
- **THEN** 输出以"📊 项目状态卡"开头，含上述字段及"➡️ 下一步"行

#### Scenario: 下一步随阶段变化

- **WHEN** stage 为 `idea`
- **THEN** 下一步提示为运行 `product-analysis`；stage 为 `planned` 时提示可直接 `dev`

### Requirement: 校验并自动补全 AGENTS.md 路由段

`using-code-compass` SHALL 校验 `AGENTS.md` 是否包含 code-compass 路由段（MARKER 包裹），
缺失时自动追加，已存在时跳过。

#### Scenario: AGENTS.md 缺失路由段

- **WHEN** `AGENTS.md` 不存在或不含 `# >>> code-compass >>>` 标记
- **THEN** 注入/追加路由段，输出对应日志

#### Scenario: AGENTS.md 已含路由段

- **WHEN** `AGENTS.md` 已含标记
- **THEN** 跳过，输出"已包含 code-compass 路由段"，不重复注入

### Requirement: 幂等且无交互阻塞

重复运行 `using-code-compass` SHALL 不产生副作用（不覆盖已有 `.harness`/rules/AGENTS 段），
且在非 TTY / agent 调用下不卡住等待输入。

#### Scenario: 重复运行

- **WHEN** 连续两次运行 `using-code-compass`
- **THEN** 第二次不重复 init，AGENTS.md 不被重复包裹，状态卡正常输出
