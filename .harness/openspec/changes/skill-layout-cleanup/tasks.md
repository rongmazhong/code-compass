# Tasks: skill-layout-cleanup

> 将 spec 的 Requirements 拆成可独立验证的实施步骤。每完成一项勾选 [x]。
> 原则：测试先行 + 行为不变。本变更取代 lib/scripts 双层，收敛为规范 skill 形态。

## 1. 准备 · 测试先行（依赖：无）

- [ ] T1 将 `skills/code-compass/tests/` 复制/移动到仓库根 `tests/code-compass/`，测试用相对路径指向 `scripts/`
- [ ] T2 在 `tests/code-compass/` 先跑一遍现有 run_smoke / skill_native 作为基线（绿）

## 2. 折叠 lib → scripts（依赖：T2）

- [ ] T3 新建 `scripts/_common.sh`：并入 `lib/{json,state,stages,detect,docs,worktree}.sh` 全部函数
- [ ] T4 将 `lib/cmds/*.sh` 的 `cmd_*` 逻辑内联进对应 `scripts/<x>.sh`（或集中 `scripts/_cmds.sh` 由 _common 附带 source）
- [ ] T5 各 `scripts/<x>.sh` 改为 `source "$_dir/_common.sh"` + 直接实现，去除对 `lib/` 的任何引用
- [ ] T6 删除 `lib/` 目录（含 `lib/cmds/`）；`grep -rn "lib/" skills/code-compass` 仅剩 `_common.sh` 自身

## 3. 移出 tests 与产物隔离（依赖：T1）

- [ ] T7 删除 `skills/code-compass/tests/`，确认 `skills/code-compass/` 顶层无 `tests/`
- [ ] T8 修正 `tests/code-compass/` 用例：R4(`commit` 测试)等改为在隔离临时目录操作并清理，杜绝 `_t` 落 cwd
- [ ] T9 `.gitignore` 屏蔽 `_t` 及测试临时产物

## 4. 清理残留（依赖：T6）

- [ ] T10 删除仓库内 `_t` 等 stray 文件（`find . -name '_t' -not -path './.git/*'` 为空）
- [ ] T11 全仓 `grep -rn "code-compass " docs/ README.md skills/code-compass` 无命令式引用（仅产品名）

## 5. 文档同步（依赖：T6）

- [ ] T12 更新 `docs/architecture.md` 目录结构：单层 `scripts/`，无 `lib/`、无运行时 `tests/`
- [ ] T13 更新 `README.md` 目录结构：同上，并注明 `tests/` 不随 skill 包分发

## 6. 验证与收尾（依赖：全部）

- [ ] T14 `bash -n` 全 `scripts/*.sh` 通过
- [ ] T15 `tests/code-compass/run_smoke.sh` 全绿（init 幂等 / guard / commit VAPD / state / upgrade / qa）
- [ ] T16 存量已 init 项目：在目标项目跑 `bash scripts/init-harness.sh` 等，行为不变
- [ ] T17 完成前验证（verification-before-completion）
