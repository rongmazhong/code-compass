# Specification: cli-modular

将 ~2000 行单文件 CLI 重构为"瘦主脚本 + 关注点 lib"结构，**不改变任何命令的外部行为**，
并新增 `bats` 集成测试作为回归护城河（先于拆分变绿）。

## ADDED Requirements

### Requirement: JSON 抽象层抽至 lib/json.sh

系统 SHALL 将 `_json_valid` / `_json_get` / `_json_get_bash` / `_json_set` / `_json_set_bash` /
`_json_add_completed` 迁移到 `skills/code-compass/lib/json.sh`，且**保留 `jq → bash` 两层降级**，
不删除 bash 兜底、不重新引入 python3。

#### Scenario: 原样保留 jq→bash 兜底

- **Given** 环境仅含 bash、无 jq
- **When** 调用 `_json_get` / `_json_set`
- **Then** 走 `_json_get_bash` / `_json_set_bash` 分支，行为与重构前一致

#### Scenario: 迁移后命令读写正常

- **Given** 已 `source lib/json.sh`
- **When** `status` / `commit` 读写 `workflow-state.json`
- **Then** 状态读写结果与重构前字节级一致

### Requirement: 状态层抽至 lib/state.sh

系统 SHALL 将 `_state_file` / `_state_ensure_file` / `_state_migrate` / `_state_active` /
`_state_list` / `_state_get` / `_state_get_for` / `_state_set` / `_state_ensure` /
`_set_vapd` / `_set_stage` / `_set_track` 迁移到 `lib/state.sh`。

#### Scenario: 并行多变更状态读写

- **Given** `workflow-state.json` 为内嵌多对象 schema
- **When** `product-analysis a` 与 `product-analysis b` 先后执行
- **Then** 两变更互不覆盖，`_state_active` / `_state_get` 按 slug 返回正确值

#### Scenario: 旧结构迁移幂等

- **Given** 一份旧扁平结构 state（含 `spec` 字段）
- **When** 触发 `_state_migrate`
- **Then** 转换为新 schema 且仅执行一次（重复触发无副作用）

### Requirement: 阶段/档位层抽至 lib/stages.sh

系统 SHALL 将 `_track_stages` / `_stage_chain` / `_next_stage_in_track` /
`_stage_cmd` / `_stage_action` / `_can_code` 迁移到 `lib/stages.sh`。

#### Scenario: track 阶段链裁剪

- **Given** `config.json` 定义 `tracks.small`（无 `reviewed`）
- **When** `status activate` 在 `verified`/`small` 阶段运行
- **Then** 输出 wiki 相关命令而非 `code-compass review`（被裁剪阶段跳过）

#### Scenario: 默认标准链

- **Given** 未指定 track（standard）
- **When** `status activate` 在 `verified` 阶段运行
- **Then** 输出 `code-compass review`

### Requirement: 项目探测与规则生成抽至 lib/detect.sh

系统 SHALL 将 `_detect_project` / `_gen_rules` / `_dir_roles` / `_has` /
`_coding_rules` / `_gen_guard_rules` / `_fill_overview` 迁移到 `lib/detect.sh`。

#### Scenario: init 探测信号

- **Given** 一个含 `Makefile` 的项目
- **When** `init`
- **Then** `rules/workflow.md` 含构建/测试命令，且 `config.json` 含 `tracks`

#### Scenario: 未识别项目

- **Given** 一个无已知信号的项目
- **When** `_detect_project`
- **Then** 构建命令标注 `未识别（请手动填写）`，不报错退出

### Requirement: 文档生成抽至 lib/docs.sh

系统 SHALL 将 `_gen_docs` / `_gen_index` / `_write_doc` / `_tree` /
`_module_rows` 迁移到 `lib/docs.sh`，保持 `docs/` 生成结果不变。

#### Scenario: init 生成 wiki

- **Given** 空项目执行 `init`
- **Then** `docs/` 含 overview/architecture/modules/api + INDEX，内容与重构前一致

### Requirement: worktree 管理抽至 lib/worktree.sh

系统 SHALL 将 `_setup_worktree` 迁移到 `lib/worktree.sh`。

#### Scenario: dev 创建 worktree

- **Given** `code-compass dev <slug>` 在 planned 阶段执行
- **Then** 在 `.worktrees/<slug>` 创建 `feat/<slug>` 分支，行为不变

### Requirement: 命令实现抽至 lib/cmds/*.sh

系统 SHALL 将 `cmd_use` / `cmd_init` / `cmd_product_analysis` / `cmd_dev` /
`cmd_worktree` / `cmd_vapd` / `cmd_commit` / `cmd_wiki` / `cmd_guard` /
`cmd_status` / `cmd_qa` / `cmd_verify` / `cmd_review` / `cmd_help` 迁移到
`lib/cmds/*.sh`（按命令分文件）。

#### Scenario: 命令经 dispatch 可达

- **Given** main 末尾 `case "$cmd"` 分发
- **When** 运行 `code-compass status` / `code-compass qa`
- **Then** 正确调用 `lib/cmds/` 中对应函数，输出与重构前一致

#### Scenario: --append / --force 仍可用

- **Given** `product-analysis --append` / `--force`
- **When** 执行
- **Then** issues.md 追加 / 跳过交互命名，行为不变

### Requirement: 主脚本瘦身为 bootstrap + source + dispatch

系统 SHALL 将 `code-compass` 主文件重构为：解析并 `export CC_ROOT`、设置
`TARGET_DIR`/`STATE_FILE`/`ISSUES_FILE` 等全局变量、`source lib/*.sh` 与
`lib/cmds/*.sh`、末尾 `case "$cmd"` 分发。

#### Scenario: CC_ROOT 仅解析一次

- **Given** lib 文件通过 `$CC_ROOT` 引用 `harness/` 与 `templates/`
- **When** main 启动
- **Then** `CC_ROOT` 在 main 中解析一次并 `export`，lib 内 `BASH_SOURCE[0]` 不导致路径错误

#### Scenario: 拆分后 main 显著变短

- **Given** 全部 lib 迁移完成
- **When** 统计 main 行数
- **Then** 仅含 bootstrap + source + dispatch（显著低于 2000 行）

### Requirement: 新增 bats 集成测试（先于拆分变绿）

系统 SHALL 在 `skills/code-compass/tests/` 提供 `bats` 集成测试，覆盖：
`guard` 拦截/放行、`commit` VAPD 校验与 `--exempt`、`status` 多变更与 track 链、
`init` 生成的 `config.json` 含 `tracks` 且 `workflow-state.json` 为新 schema。
**测试须在拆分开始前于现有巨石上已变绿**，拆分全程保持全绿。

#### Scenario: init 模板防回归

- **Given** 临时 `TARGET_DIR` 执行 `init`
- **When** 检查生成的 `config.json` 与 `workflow-state.json`
- **Then** `config.json` 含 `tracks`、`workflow-state.json` 为新 schema（覆盖已修复的模板 bug）

#### Scenario: guard 闸门

- **Given** 状态处于 `idea` 阶段
- **When** `guard`
- **Then** 非 0 退出（拦截）；处于 `planned` 及以后则 0 退出（放行）
