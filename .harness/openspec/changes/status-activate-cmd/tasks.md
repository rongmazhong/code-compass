# Tasks: status-activate-cmd

> 将 spec 的 Requirements 拆成可独立验证的实现步骤。每完成一项勾选 [x]。

## 1. 准备

- [x] 新增 `_next_stage_in_track` / `_stage_cmd` 辅助函数

## 2. 实现（按 Requirement 拆解）

- [x] Requirement 1: status activate 输出可直接复制执行的命令（按阶段映射）
  - [x] 验证：verified → `code-compass review`；planned → `code-compass dev <slug>`
- [x] Requirement 2: activate 命令随 track 裁剪（被裁剪阶段跳过）
  - [x] 验证：small/verified → wiki（reviewed 被跳过）；research/dev → wiki（qa 被跳过）
- [x] Requirement 3: 命令内带入真实 slug（planned → `code-compass dev demo`）

## 3. 验证

- [x] 运行测试套件 / lint（`bash -n` 语法校验通过）
- [x] 手动验证：临时项目覆盖 4 种 阶段×track 组合
- [x] 完成前验证（verification-before-completion）
