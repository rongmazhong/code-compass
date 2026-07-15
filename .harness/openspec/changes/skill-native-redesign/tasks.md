# Tasks: skill-native-redesign

> 将 spec 的 Requirements 拆成可独立验证的实施步骤。每完成一项勾选 [x]。
> 原则：**测试先行**，每动一处跑 `bash -n` + 相关 smoke 保持绿。本方案取代并吸收 `cli-modular`。

## 1. 准备 · 测试先行（依赖：无）

- [x] T1 引入 `bats` 骨架：`skills/code-compass/tests/` + `test_helper`（用临时 `TARGET_DIR`）
- [x] T2 写 `guard.bats`：`idea` 拦截（非0）/ `planned+` 放行（0）（R6）
- [x] T3 写 `commit.bats`：VAPD 格式校验、`--exempt` 豁免（R4/R5）
- [x] T4 写 `state.bats`：get/set stage、vapd_id、list、active（R4/R7）
- [x] T5 写 `init.bats`：**防回归**——生成 `config.json` 含 `tracks`、`workflow-state.json` 新 schema、幂等（R4/R8）
- [x] T6 在**现有结构**上跑全量 bats 变绿（基线，先于改造）

## 2. 抽 scripts 工具层（依赖：T6，可单测后逐个落地）

- [x] T7 `scripts/state.sh`（R4）：迁移 JSON/状态读写，保留 jq→bash 兜底；`bash -n` + bats 绿
- [x] T8 `scripts/guard.sh`（R5/R6）：阶段闸门退出码
- [x] T9 `scripts/init-harness.sh`（R4/R8）：铺 `.harness/`+`docs/`+AGENTS 路由，幂等
- [x] T10 `scripts/worktree.sh`（R4）：create/list/prune
- [x] T11 `scripts/commit.sh`（R4/R5）：拼 `<type>: #{VAPD_ID}#<desc>` + git commit
- [x] T12 `scripts/wiki.sh` + `scripts/vapd.sh`（R4）：文档生成、VAPD 记录/显示
- [x] T13 `scripts/upgrade.sh`（R4）：刷新 harness config/state（吸收 `upgrade` 子命令逻辑）

## 3. 重排子 skill（依赖：T7–T13）

- [x] T14 重写 12 个子 `SKILL.md` 的 description 为意图触发、pushy、覆盖口语说法（R3）
- [x] T15 重写子 skill 正文：方法论散文（解释 why）+ 机械步改调 `scripts/*`（R3）；`dev`/`commit` 开头调 `guard.sh`（R5/R6）
- [x] T16 重写顶 `SKILL.md`：命令表 → 意图触发地图；删 alias/PATH/python3 前置（R2）

## 4. 去命令化与移除 CLI（依赖：T14–T16）

- [x] T17 更新 `harness/AGENTS.md.harness` 路由段：去 `code-compass <cmd>` → 子 skill/脚本（R7）
- [x] T18 更新 README：安装零门槛、去除 `code-compass <cmd>` 示例、补 `scripts/*` 直跑说明（R1/R2）
- [x] T19 **删除** `skills/code-compass/code-compass` 及任何 `cc.sh` 别名壳（R1）
- [x] T20 全仓 grep `code-compass <cmd>` 字面引用，清零（R1）

## 5. 触发率评测与收尾（依赖：T14）

- [x] T21 用 skill-creator `run_loop` 对 12 个子 skill description 跑触发率评测，达阈值（R9）
- [x] T22 `bash -n` 对全部 `scripts/*.sh` 通过；`shellcheck`（可选）无致命告警
- [x] T23 全量 bats 通过 + 手动 smoke：子 skill 加载后 `product-analysis`→生成 spec、`dev` 经 `guard.sh`、`commit` 格式正确、存量项目续跑
- [x] T24 验证存量已 init 项目：移除 CLI 后 state/openspec 仍可读取续跑（R1/R7）
- [x] T25 完成前验证（verification-before-completion）；标记 `cli-modular` 退休（被本方案取代）
