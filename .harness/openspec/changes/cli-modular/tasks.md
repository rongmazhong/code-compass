# Tasks: cli-modular

> 将 spec 的 Requirements 拆成可独立验证的实施步骤。每完成一项勾选 [x]。
> 原则：**先测试后拆**，每抽一个 lib 跑 `bash -n` + 全量 bats 保持绿。

## 1. 准备 · 测试先行（依赖：无）

- [ ] T1 引入 `bats` 测试骨架：`skills/code-compass/tests/` + `test_helper`（用临时 `TARGET_DIR`）
- [ ] T2 写 `guard.bats`：idea 拦截（非0）/ planned+ 放行（0）
- [ ] T3 写 `commit.bats`：VAPD 格式校验、`--exempt` 豁免
- [ ] T4 写 `status.bats`：多变更并行、`--all`、track 阶段链（small 裁剪）
- [ ] T5 写 `init.bats`：**防回归**——生成 `config.json` 含 `tracks`、`workflow-state.json` 新 schema
- [ ] T6 在**现有巨石**上跑全量 bats 变绿（基线）

## 2. 重构（依赖：T6，可单测后逐个抽）

- [ ] T7 JSON 层 → `lib/json.sh`（R1）；`bash -n` + bats 绿
- [ ] T8 状态层 → `lib/state.sh`（R2）；bats 绿
- [ ] T9 阶段/档位 → `lib/stages.sh`（R3）；bats 绿
- [ ] T10 探测/规则 → `lib/detect.sh`（R4）；bats 绿
- [ ] T11 文档生成 → `lib/docs.sh`（R5）；bats 绿
- [ ] T12 worktree → `lib/worktree.sh`（R6）；bats 绿
- [ ] T13 命令 → `lib/cmds/*.sh`（R7，按命令分文件）；bats 绿
- [ ] T14 主脚本瘦身：bootstrap + `export CC_ROOT` + `source lib/*` + dispatch `case`（R8）；bats 绿

## 3. 验证（依赖：T14）

- [ ] T15 `bash -n` 对 main 及全部 `lib/*.sh`、`lib/cmds/*.sh` 通过
- [ ] T16 `shellcheck`（可选）对新增文件无致命告警
- [ ] T17 全量 bats 通过；手动 smoke：`status --all` / `qa` / `verify` / `review` / `product-analysis --append` / `--force` 行为不变
- [ ] T18 验证 main 行数显著下降（仅 bootstrap+source+dispatch）
- [ ] T19 完成前验证（verification-before-completion）
