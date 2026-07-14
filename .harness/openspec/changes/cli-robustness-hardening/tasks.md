# Tasks: cli-robustness-hardening

> 将 spec 的 Requirements 拆成可独立验证的实现步骤。每完成一项勾选 [x]。

## 1. 准备

- [ ] 在 `code-compass` 脚本中新增 `_json_get` / `_json_set` 抽象层（jq 优先，纯 bash 兜底）
- [ ] 新增 `_atomic_write <file> <content>` 辅助函数

## 2. 实现（按 Requirement 拆解）

- [ ] R1 `JSON 读写去 Python 化`
  - [ ] 用 `_json_get` / `_json_set` 替换 `_state_get` / `_set_vapd` / `_set_stage` / `_stage_chain` / `cmd_status` 中的 python 调用
  - [ ] 无 jq 且无 python3 时输出降级提示
- [ ] R2 `闸门豁免环境变量生效`
  - [ ] 在 `cmd_guard` / `cmd_commit` / `cmd_dev` 闸门分支开头检查 `CODE_COMPASS_GUARD=off` 并提前返回 0
- [ ] R3 `status 健壮解析状态`
  - [ ] `cmd_status` 单次解析、`get(...,"")` 兜底、去除逐字段子进程
- [ ] R4 `区分未初始化与状态文件损坏`
  - [ ] `_can_code` 区分文件不存在(2) / JSON 非法(明确报错) / 阶段不符(拦截)
- [ ] R5 `product-analysis 默认 spec 落点`
  - [ ] `cmd_product_analysis` 落地 `specs/core/spec.md`，移除字面量 `<capability>`
- [ ] R6 `worktree 路径内聚`
  - [ ] `_setup_worktree` 改为 `TARGET_DIR/.worktrees/<slug>`，追加 `.gitignore`
- [ ] R7 `状态文件原子写入`
  - [ ] `_set_stage` / `_set_vapd` 经 `_atomic_write` 写入

## 3. 验证

- [ ] 在无 `python3` 环境（或临时 `alias python3=none`）下跑通 `init` / `product-analysis` / `dev` / `commit` / `status` / `guard`
- [ ] `CODE_COMPASS_GUARD=off code-compass guard` 退出码为 0
- [ ] 手动损坏 `workflow-state.json` 后 `guard` 给出"损坏"明确错误
- [ ] `product-analysis` 产物无字面量 `<capability>` 目录
- [ ] `dev` 创建的 worktree 位于 `<TARGET_DIR>/.worktrees/<slug>` 且 `.gitignore` 已更新
- [ ] `bash -n` 语法检查通过；对照 AGENTS.md 流程自测
