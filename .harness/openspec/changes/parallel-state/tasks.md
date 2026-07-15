# Tasks: parallel-state

> 将 spec 的 Requirements 拆成可独立验证的实现步骤。每完成一项勾选 [x]。

## 1. 准备

- [x] 在 CLI 中新增状态读写抽象层，统一从 `changes[active]` 读写（替代直接读写顶层字段）

## 2. 实现（按 Requirement 拆解）

- [x] Requirement 1: 内嵌多对象状态 schema（`_state_get`/`_state_set` 基于 active）
  - [x] 编写失败测试（红）→ 实现并通过（绿）——以 CLI 实跑验证（无 bats 框架）
- [x] Requirement 2: 状态写入按活跃变更隔离（改造 `_set_stage`/`_state_set`）
  - [x] 验证：新增 test2 变更仅写入 changes[test2]，parallel-state 保持 dev
- [x] Requirement 3: status 作用于 active 且支持 --all
  - [x] 验证：`status --all` 列出全部 6 个变更及阶段
- [x] Requirement 4: 旧扁平 schema 兼容迁移（读取时自动转换写回）
  - [x] 验证：运行 `status` 将旧扁平文件迁移为内嵌多对象并写回

## 3. 验证

- [x] 运行测试套件 / lint（`bash -n` 语法校验通过）
- [x] 手动验证：`status`/`status --all`/`guard`/`status activate` 行为正确；旧文件被迁移
- [x] 完成前验证（verification-before-completion）
