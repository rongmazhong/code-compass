# Tasks: pa-efficiency

> 将 spec 的 Requirements 拆成可独立验证的实现步骤。每完成一项勾选 [x]。

## 1. 准备

- [x] 新增 `_append_issue` 辅助函数与 `ISSUES_FILE` 路径变量

## 2. 实现（按 Requirement 拆解）

- [x] Requirement 1: 合并 decision-log / 用户偏好 / 决策记录 到单一 `.harness/issues.md`
  - [x] 验证：init 生成 issues.md（含说明头部）
- [x] Requirement 2: `product-analysis --append` 把澄清/决策追加到 issues.md，不重建 spec
  - [x] 验证：STDIN / 单参数 / `<slug> 文本` 三种形式均追加成功
- [x] Requirement 3: 保留跳过 prompt 的能力（`--force` 直接建工作区，不交互命名）
  - [x] 验证：`product-analysis --force demo-y` 跳过 read 提示直接创建

## 3. 验证

- [x] 运行测试套件 / lint（`bash -n` 语法校验通过）
- [x] 手动验证：临时项目覆盖 init / --append 三形式 / --force
- [x] 完成前验证（verification-before-completion）
