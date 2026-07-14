# Tasks: using-code-compass-onboard

> 将 spec 的 Requirements 拆成可独立验证的实现步骤。每完成一项勾选 [x]。

## 1. 准备

- [x] 变更目录与 spec 骨架（product-analysis 已生成）

## 2. 实现（按 Requirement 拆解）

- [x] Requirement: 未初始化项目自动 init
  - [x] cmd_use 检测 `.harness`，缺失则调用 cmd_init
  - [x] 已存在时打印"已初始化"跳过
- [x] Requirement: 内联报告项目状态卡
  - [x] 新增 `_print_state_card` 读取 workflow-state.json 并打印
  - [x] 新增 `_next_step` 按 stage 推导下一步
  - [x] cmd_use 末尾调用 `_print_state_card`
- [x] Requirement: 校验并自动补全 AGENTS.md 路由段
  - [x] 新增 `_ensure_agents_md`（幂等）
  - [x] cmd_use 调用 `_ensure_agents_md`；cmd_init 复用同一函数
- [x] Requirement: 幂等且无交互阻塞
  - [x] 所有写操作带存在性/标记判定，不覆盖、不阻塞

## 3. 验证

- [x] 已 init 项目运行（输出状态卡，不重复 init）
- [x] 未 init 临时项目运行（自动 init + 状态卡 + AGENTS 注入）
- [x] 同步到 ~/.agents/skills/code-compass 实时生效
- [ ] 运行测试套件 / lint / 类型检查（纯 Bash，无独立测试套件，已做 smoke 验证）
- [x] 完成前验证（verification-before-completion）
