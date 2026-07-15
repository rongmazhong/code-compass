# Spec: cc-upgrade

> OpenSpec 风格的能力 spec（delta）。描述目标状态，每条 Requirement 须可验证。

## ADDED Requirements

### Requirement: upgrade-refresh-config

系统 SHALL 在 `code-compass upgrade` 时，把当前项目 `.harness/config.json` 刷新到新模板的**顶层缺省键**
（`tracks` / `stages` 等），**仅补缺失键、不删用户键、不覆盖用户已填值**。

#### Scenario: 正常路径（缺 tracks 的老项目）

- **WHEN** 当前项目 `.harness/config.json` 存在但**缺 `tracks`** 键
- **THEN** `upgrade` 把模板的 `tracks` 合并进该文件，用户原有的其它键（如 `skills_dir`、`state_dir`）保持不变，`exit 0`

#### Scenario: 边界 / 异常路径（已含 tracks）

- **WHEN** `config.json` 已含 `tracks` 且与模板一致
- **THEN** `upgrade` 不改写该文件，打印"config 已是最新"，`exit 0`

### Requirement: upgrade-refresh-state

系统 SHALL 在 `code-compass upgrade` 时，确保当前项目 `.harness/state/workflow-state.json`
的**每个 change 含 `updated_at` 字段**，并重用既有 `_state_migrate` 处理任何 schema 缺口，
**完整保留 `changes` / `completed` / `issues.md` / `openspec/` 全部用户数据**。

#### Scenario: 正常路径（缺 updated_at 字段）

- **WHEN** 某 change 缺 `updated_at` 字段
- **THEN** `upgrade` 补该字段（默认空串），其余字段（stage/branch/track/vapd_id/completed）原样保留，`exit 0`

#### Scenario: 边界 / 异常路径（已是最新）

- **WHEN** 所有 change 均已含 `updated_at` 且 schema 无缺口
- **THEN** `upgrade` 幂等无副作用，打印"state 已是最新"，`exit 0`

### Requirement: upgrade-scope-locked

系统 SHALL 在 `code-compass upgrade` 时**仅触碰 harness 配置**（`config.json` + `workflow-state.json`），
**不读写** `.harness/rules/`、`AGENTS.md` 路由段、`openspec/` 与 `issues.md` 之外的用户资产。

#### Scenario: 正常路径（确认不越界）

- **WHEN** 运行 `upgrade`
- **THEN** `rules/` 下文件 mtime 不变、`AGENTS.md` 内容不变、用户已填的 `openspec/changes/<slug>/` 与 `issues.md` 保持原样

### Requirement: upgrade-self-backup-merge

系统 SHALL 在 `code-compass upgrade --self` 时，先**备份**当前安装目录 `$CC_ROOT` 内用户改过的
`skills/*/SKILL.md` 与 `rules/`，再从 `config.json` 的 `upgrade_source` 拉取最新 skill 库并**合并**用户备份回去；
若 `upgrade_source` 未配置，则跳过自升级并提示配置方式。

#### Scenario: 正常路径（已配置 upgrade_source）

- **WHEN** `config.json` 含 `upgrade_source` 且用户改过某 `SKILL.md`
- **THEN** `upgrade --self` 先把改动备份到 `.harness.bak/`，拉取最新库后把备份的 `SKILL.md` 还原覆盖，`exit 0`

#### Scenario: 边界 / 异常路径（未配置源）

- **WHEN** `upgrade --self` 但 `config.json` 无 `upgrade_source`
- **THEN** 仅打印"未配置 upgrade_source，跳过自升级；项目级刷新仍执行"，不报错退出
