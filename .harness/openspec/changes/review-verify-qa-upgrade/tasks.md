# Tasks: review-verify-qa-upgrade

> 将 spec 的 Requirements 拆成可独立验证的实现步骤。每完成一项勾选 [x]。
> 映射约定：Requirement → test 行供 verify 弱校验使用。

## 1. 准备

- [x] 创建 review-product.sh / review-eng.sh / review-security.sh / review-design.sh 子脚本（source _common.sh，暴露 cmd_review_*）

## 2. 实现（按 Requirement 拆解）

- [x] Requirement: review-multi-perspective
  - [x] 实现 cmd_review_product / cmd_review_eng / cmd_review_security / cmd_review_design（grep/静态检查，零依赖）
  - test: tests/code-compass/review_multi_perspective.bats
  - [x] 改写 cmd_review 为编排入口，依次调用四视角并汇总
  - test: tests/code-compass/review_orchestrate.bats

- [x] Requirement: review-stage-advance
  - [x] cmd_review 末尾调用 _set_stage reviewed（非致命失败时）
  - test: tests/code-compass/review_stage.bats

- [x] Requirement: verify-multi-dimensional
  - [x] cmd_verify 改为四维结构化输出（spec覆盖/测试状态/文档同步/提交规范）
  - test: tests/code-compass/verify_multi.bats

- [x] Requirement: verify-spec-coverage-mapping
  - [x] 解析 tasks.md 的 `Requirement → test` 映射行做弱校验
  - test: tests/code-compass/verify_mapping.bats

- [x] Requirement: qa-web-browser-integration
  - [x] cmd_qa 不新增 label，复用"测试"命令；web 工程配置 agent-browser 时自然执行
  - test: tests/code-compass/qa_web.bats

- [x] Requirement: qa-skill-web-guidance
  - [x] 在 skills/qa/SKILL.md 增加前端 web 工程 agent-browser 引导散文
  - test: 人工复核 SKILL.md 含引导段

## 3. 验证

- [x] 运行 tests/code-compass 全套 smoke + 新增 bats 测试
- [x] 在示例 web 变更上验证 qa 接 agent-browser 路径（可选）
- [x] 完成前验证：bash scripts/verify.sh 四维全绿
