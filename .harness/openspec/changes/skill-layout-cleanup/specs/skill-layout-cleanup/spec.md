# Specification: skill-layout-cleanup

> OpenSpec 风格的能力 spec（delta）。目标状态：`skills/code-compass` 收敛为规范 skill 形态——
> 指导(markdown) + 唯一代码目录 `scripts/`（自包含可运行）。删除 `lib/`，`tests/` 移出运行时目录。

## ADDED Requirements

### Requirement: 删除 lib/ 并折叠入 scripts

系统 SHALL 删除 `skills/code-compass/lib/`（`lib/*.sh` 与 `lib/cmds/*.sh`）；
将其函数实现并入 `scripts/_common.sh`（共享助手：json/state/stages/detect/docs/worktree）
与各 `scripts/<x>.sh`（对应能力的 `cmd_*` 逻辑内联或集中到 `scripts/_cmds.sh` 被 _common 附带 source）。

#### Scenario: lib 目录消失

- **WHEN** 检查 `skills/code-compass/` 顶层
- **THEN** 不存在 `lib/` 目录；全仓 `grep -rn "lib/" skills/code-compass` 仅命中 `scripts/_common.sh` 自身

#### Scenario: 能力逻辑不丢

- **WHEN** 对比重构前后 `init`/`guard`/`commit`/`state`/`upgrade` 等能力的行为
- **THEN** 输出与重构前字节级一致（`tests/code-compass/run_smoke.sh` 全绿）

### Requirement: scripts 自包含化

系统 SHALL 使每个 `scripts/<x>.sh` 在 `source "$_dir/_common.sh"` 后直接实现其能力，
不再依赖被删除的 `lib/`；`scripts/_bootstrap.sh`（如仍被引用）统一并入或改名为 `_common.sh`。

#### Scenario: 脚本独立可运行

- **WHEN** 终端用户直接 `bash scripts/init-harness.sh`（从任意 cwd）
- **THEN** 行为正确，且不引用任何已删除的 `lib/` 路径

### Requirement: tests 移出运行时目录

系统 SHALL 将 `skills/code-compass/tests/` 移至仓库根 `tests/code-compass/`，
使其不随 skill 包分发；测试脚本用相对路径指向 `scripts/`，断言与现有 run_smoke / skill_native.bats 一致。

#### Scenario: 测试不在 skill 包内

- **WHEN** 检查 `skills/code-compass/` 顶层
- **THEN** 不存在 `tests/` 目录；`tests/code-compass/` 存在且可独立运行

#### Scenario: 测试仍覆盖回归

- **WHEN** 运行 `tests/code-compass/run_smoke.sh`
- **THEN** 与重构前相同用例全绿（init/guard/commit/state/upgrade/qa）

### Requirement: 测试产物隔离

系统 SHALL 确保测试用例在隔离临时目录内操作并清理，不再于 cwd 遗留 `_t` 等文件；
并在 `.gitignore` 屏蔽 `_t` 及测试临时产物，从机制上杜绝泄漏。

#### Scenario: 无 cwd 泄漏

- **WHEN** 运行 `tests/code-compass/run_smoke.sh` 后检查仓库根
- **THEN** 不存在 `_t` 或测试临时文件；`git status` 干净（除预期的测试输出）

### Requirement: 清理 stray 残留

系统 SHALL 删除仓库内 `_t` 等 stray 测试产物，并确保全仓无 `code-compass <cmd>` 命令式引用残留。

#### Scenario: 无 stray 与旧命令引用

- **WHEN** `find . -name '_t' -not -path './.git/*'` 与 `grep -rn "code-compass " docs/ README.md skills/code-compass`
- **THEN** 无 `_t` 文件；剩余 `code-compass ` 均为产品名而非命令调用

### Requirement: 文档同步目录结构

系统 SHALL 更新 `docs/architecture.md` 与 `README.md` 的目录结构段：
改为单层 `scripts/`（无 `lib/`），并注明 `tests/` 不随 skill 包分发。

#### Scenario: 架构文档反映单层 scripts

- **WHEN** 阅读 `docs/architecture.md` 目录布局
- **THEN** 仅列 `SKILL.md` + `skills/` + `scripts/` + `harness/` + `templates/`；无 `lib/`、无运行时 `tests/`

### Requirement: 回归验证

系统 SHALL 在改造完成后满足：`bash -n` 全 `scripts/*.sh` 通过；
`tests/code-compass/run_smoke.sh` 全绿；存量已 init 项目行为不变。

#### Scenario: 全量验证

- **WHEN** 改造结束运行 `bash -n scripts/*.sh` 与 `tests/code-compass/run_smoke.sh`
- **THEN** 语法全过、回归全绿
