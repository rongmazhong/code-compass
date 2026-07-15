# summary.md — skill-native-redesign

## 做了什么

把 code-compass 从「单文件 bash CLI 中枢」重排为「纯 skill 库 + scripts/ 机械工具层」，
消除原架构的「双重间接 + 泄漏抽象」问题，使 agent 按意图直接加载子 skill 跟方法论走。

## 关键变更

- **删除 CLI 调度器** `skills/code-compass/code-compass`（R1）。仓库内已无 `code-compass <cmd>` 命令入口。
- **新增 `scripts/` 工具层**（R4）：`_bootstrap.sh` + 15 个可独立运行的脚本
  （`init-harness`/`product-analysis`/`dev`/`worktree`/`vapd`/`commit`/`status`/`guard`/
  `qa`/`verify`/`review`/`wiki`/`upgrade`/`use`/`state`）。逻辑复用已测 `lib/*`，行为零变更。
- **子 skill 升为一等公民**（R3）：12 个 `skills/<name>/SKILL.md` 的 description 改为意图触发
  （pushy、覆盖口语说法），正文改调 `bash scripts/*.sh`，不再以「运行 code-compass X」为首选。
- **顶 SKILL.md**（R2）：命令表 → 意图→子 skill 地图；安装去 alias/PATH/python3 前置。
- **去命令化**（R7）：`harness/AGENTS.md.harness`、根 `AGENTS.md`、README、`lib/cmds/*.sh` 提示
  全部改为子 skill / `scripts/*` 引用。
- **硬约束下沉**（R5/R6）：`dev`/`commit` 子 skill 开头调 `bash scripts/guard.sh` 并解释 why。
- **测试**（R8）：`tests/run_smoke.sh`（9 项全绿）+ `tests/skill_native.bats`（bats 版）；
  `bash -n` 全 lib/scripts 通过。
- **兼容**（R7）：`workflow-state.json` / `config.json` schema 不变，存量已 init 项目不破。

## 验证

- `bash skills/code-compass/tests/run_smoke.sh` → PASS=9 FAIL=0
- 全 lib/scripts `bash -n` 通过
- `scripts/qa.sh` 通过 → `stage=verified`
- 全仓零 `code-compass <cmd>` 命令式引用（仅产品名保留）
- 所有子 skill / 模板 / README 引用的 `scripts/*.sh` 均存在

## 遗留

- **R9 触发率评测**：已生成 `trigger-eval.json`（20 条 should/should-not 查询），
  待环境具备 `claude` CLI 时以 skill-creator `run_loop.py` 跑触发率评测并据结果微调 description。
- `cli-modular` 变更被本方案取代退休（proposal 已声明）。

## 提交

`refactor: 移除 CLI 调度器，重排为纯 skill 库加 scripts 工具层`
