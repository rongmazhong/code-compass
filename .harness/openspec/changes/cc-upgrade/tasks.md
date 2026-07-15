# Tasks: cc-upgrade

> 将 spec 的 Requirements 拆成可独立验证的实现步骤。每完成一项勾选 [x]。

## 1. 准备

- [ ] 在 `lib/cmds/` 新增 `upgrade.sh`（`cmd_upgrade`，接受 `--self` 选项）
- [ ] 在 `code-compass` 主入口 `case "$cmd"` 注册 `upgrade`（含 `upgrade` / `upgrade --self`）
- [ ] 在 `skills/code-compass/SKILL.md` 核心命令表补 `upgrade` 行

## 2. 实现（按 Requirement 拆解）

- [ ] Requirement: upgrade-refresh-config（`config.json` 合并缺省键，不删不覆盖）
  - [ ] 编写失败测试（红）：构造缺 `tracks` 的 `config.json`，断言 `upgrade` 后含 `tracks` 且原键保留
  - [ ] 实现 `_config_merge` 并接入 `cmd_upgrade`（绿）
  - [ ] 重构：复用模板 `harness/config.json` 作为缺省源
- [ ] Requirement: upgrade-refresh-state（`workflow-state.json` 补 `updated_at`，重用 `_state_migrate`）
  - [ ] 编写失败测试（红）：构造缺 `updated_at` 的 state，断言 `upgrade` 后补字段且 `changes` 不变
  - [ ] 实现并接入 `cmd_upgrade`（绿）
- [ ] Requirement: upgrade-scope-locked（仅触碰 harness 配置）
  - [ ] 测试：断言 `upgrade` 后 `rules/` mtime 与 `AGENTS.md` 内容不变
- [ ] Requirement: upgrade-self-backup-merge（`upgrade --self` 备份+合并，`upgrade_source` 缺省跳过）
  - [ ] 实现备份到 `.harness.bak/` 与从 `upgrade_source` 拉取后还原用户 `SKILL.md`
  - [ ] 测试：未配置 `upgrade_source` 时跳过并提示，不报错退出

## 3. 验证

- [ ] 在老项目（缺 `tracks`）实测 `upgrade` → config 含 `tracks`、state 含 `updated_at`、数据零丢失
- [ ] 重复运行 `upgrade` 幂等无副作用
- [ ] 运行 `bash skills/code-compass/tests/run_smoke.sh`（既有回归不破）
- [ ] `verify` 核对 Requirement 与 tasks 勾选一致
