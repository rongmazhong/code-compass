# Change: review-verify-qa-upgrade

## Why

> 柏拉图式发问的结论写在这里。说明真正要解决的问题、用户对象、成功信号。
> 明确"不做什么"（非目标）。

- 问题本质：code-compass 的 review/verify/qa 三个质量关当前是"形式化"的——review 只打印静态清单、verify 只数 Requirement 与 tasks 勾选数、qa 仅 eval 测试/lint，且 review 执行后不推进阶段。对标 gstack 的多角色审查与 superpowers 的完成前验证，存在结构化短板。
- 用户对象：使用 code-compass 方法论的 agent 与开发者。
- 范围边界（MVP 必含 / 后置）：
  - 必含：review 四视角可执行链（product/eng/security/design）、verify 多维结构化验证、qa 可选浏览器测试集成（复用现有 label）、修 review 阶段不推进的 bug。
  - 后置（P1）：部署流水线、操作护栏 careful/freeze、review 自动修复深改。
- 非目标：不内置浏览器、不引入任何外部依赖、不改动 spec 模板结构、不新增 workflow.md 的 e2e label、不做 design 视角的自动修复。
- 成功信号：
  - `bash scripts/review.sh` 输出四视角检查结果且阶段推进到 reviewed
  - `bash scripts/verify.sh` 输出四维结构化报告
  - `bash scripts/qa.sh` 在 web 项目配置 agent-browser 测试命令时执行浏览器测试，未配置时跳过保持原行为
  - 既有 smoke 测试（tests/code-compass）仍全绿

## What Changes

> 一句话概述本次变更触及的能力（对应 .harness/openspec/specs 下的 capability 名）。

升级 review/verify/qa 三个质量关为可执行、分视角、零依赖的检查链，并修复 review 阶段推进缺失。

## Impact

> 影响范围：哪些模块 / 命令 / 文档会变动。

- `skills/code-compass/scripts/_common.sh`：cmd_review / cmd_verify / cmd_qa 逻辑增强，新增 cmd_review_product/eng/security/design
- 新增 `skills/code-compass/scripts/review-product.sh` `review-eng.sh` `review-security.sh` `review-design.sh`
- `skills/code-compass/skills/qa/SKILL.md`：增加 web 项目 agent-browser 引导散文
- `.harness/openspec/changes/review-verify-qa-upgrade/specs/core/spec.md`：本 spec
