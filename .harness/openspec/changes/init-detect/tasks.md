# Tasks: init-detect

> 将 spec 的 Requirements 拆成可独立验证的实现步骤。每完成一项勾选 [x]。

## 1. 准备

- [x] 梳理 `_detect_project` 当前识别分支

## 2. 实现（按 Requirement 拆解）

- [x] Requirement 1: 扩充技术栈信号识别（Make/Just/Cargo[已有]/DotNet/CMake/Elixir/Docker/Shell）
  - [x] 验证：临时 Rust/Make/DotNet 项目 init 后 `语言` 正确识别
- [x] Requirement 2: 识别失败显式标注（未知→未识别（请手动填写））
  - [x] 验证：空项目 init 后 `语言：未识别（请手动填写）`，无“未知”字样
- [x] Requirement 3: 识别包管理器时预填 workflow 命令
  - [x] 验证：Rust→cargo test/clippy；Make→make test/lint；空项目保留占位

## 3. 验证

- [x] 运行测试套件 / lint（`bash -n` 语法校验通过）
- [x] 手动验证：对 Rust/Make/DotNet/空 样例目录 init，核对语言与 workflow.md 命令
- [x] 完成前验证（verification-before-completion）
