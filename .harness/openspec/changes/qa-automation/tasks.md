# Tasks: qa-automation

> 将 spec 的 Requirements 拆成可独立验证的实现步骤。每完成一项勾选 [x]。

## 1. 准备

- [x] 新增 `cmd_qa`/`cmd_verify`/`cmd_review` 路由入口

## 2. 实现（按 Requirement 拆解）

- [x] Requirement 1: qa 命令消费 workflow.md 并推进（解析测试/lint 字段 + 自动推进 verified）
  - [x] 验证：测试/lint 命令成功 → 推进 verified；命令 `false` 失败 → 不推进
- [x] Requirement 2: verify 命令比对覆盖度（spec Requirements ↔ tasks 勾选）
  - [x] 验证：2 需求 / 1 勾选 → 报 1 条未覆盖；全勾选 → 通过
- [x] Requirement 3: review 命令生成审查包（diff stat + spec 摘要 + checklist）
  - [x] 验证：运行 review 输出变更统计、Requirement 列表与清单

## 3. 验证

- [x] 运行测试套件 / lint（`bash -n` 语法校验通过）
- [x] 手动验证：临时项目上 qa 通过/失败、verify 覆盖度、review 审查包
- [x] 完成前验证（verification-before-completion）
