# proposal.md — skill-layout-cleanup

## 问题本质

`skills/code-compass` 作为「指导型 skill 库」，运行时目录却混入了软件项目的结构：
`lib/`(6) + `lib/cmds/`(13) 的函数层 + `scripts/`(16) 的薄壳层 + `tests/` 内置 + cwd 残留 `_t`。
根因是两次重构叠加未收尾：`cli-modular` 把巨石拆成 `lib/`（只被 source、不可运行），
`skill-native-redesign` 在其上又包了一层 `scripts/`（薄壳调 `cmd_*`）。结果同一份逻辑
存在两层（lib 一份、scripts 调一遍），且测试与产物残留在 skill 运行时目录，违背
skill-creator「唯一代码目录 = `scripts/`」的规范，也让"指导库"看起来像"半成品项目"。

## 档位（tier）

**refactor（重构）**——不新增功能，只收敛目录结构、消除 lib/scripts 双层、把 tests 移出运行时目录。

## 关键决策（已与用户确认）

1. **选项 A（保留自包含引擎，只清理布局）**：README 承诺"自包含"，引擎须随 skill 走；
   故不拆外部工具，仅把 `lib/` 折叠进 `scripts/_common.sh` + 对应 `scripts/x.sh`。
2. **`lib/` 整体删除**：其函数并入 `scripts/_common.sh`（共享）与 `scripts/x.sh`（各能力自实现）。
3. **`tests/` 移出运行时目录**：`skills/code-compass/tests/` → 仓库根 `tests/code-compass/`，
   不随 skill 包分发；测试用相对路径指向 `scripts/`。
4. **测试产物隔离**：用例在隔离临时目录操作并清理，从机制上杜绝 `_t` 类 cwd 泄漏；`.gitignore` 屏蔽 `_t` 及产物。
5. **不破坏行为**：所有对外能力（init/guard/commit/state/upgrade/wiki/worktree/vapd/status/qa…）行为不变，仅重排文件位置。

## 非目标（边界）

- 不新增任何用户可见功能；本次只重排目录与文件归属。
- 不改动各能力的业务逻辑/输出格式（仅搬运函数实现位置）。
- 不引入外部引擎或拆分独立仓库（即不做选项 B）。
- 不改动 `workflow-state.json` / `config.json` 既有 schema。

## 成功信号（可观测）

- 仓库根 `skills/code-compass/` 下**不再存在 `lib/` 与 `tests/`**；仅 `SKILL.md` + `skills/` + `scripts/` + `harness/` + `templates/`。
- 全仓 `grep -rn "lib/" skills/code-compass` 零引用（除 `scripts/_common.sh` 自身）。
- `bash -n` 对全部 `scripts/*.sh` 通过。
- `tests/code-compass/run_smoke.sh` 全绿（init 幂等 / guard 闸门 / commit VAPD / state 读写 / upgrade / qa），行为与重构前一致。
- 全仓无 `code-compass <cmd>` 命令式引用；`./_t` 等 stray 文件清零。
- `docs/architecture.md` 与 `README.md` 目录结构改为单层 `scripts/`，并注明 tests 不随包分发。
