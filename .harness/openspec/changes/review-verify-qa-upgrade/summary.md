# summary.md — review-verify-qa-upgrade

## 做了什么

把 code-compass 三个质量关（review / verify / qa）从「形式化清单」升级为「可执行、分视角、零依赖」的检查链，并修复 review 执行后不推进阶段的缺陷。对标 gstack 的多角色审查与 superpowers 的完成前验证，补齐结构性短板，同时保持 code-compass 的零依赖哲学。

## 关键变更

- **review 多视角审查链**（P0-1）：`cmd_review` 从静态 5 条清单重写为 product / eng / security / design 四视角编排入口，依次执行并汇总报告。
  - product：逐条 SHALL 对齐（顾问性，不阻断）
  - eng：N+1 / 竞态 / 信任边界 / 错误处理降级（顾问性 ⚠️）
  - security：硬编码密钥（❌ 高置信，唯一致命阻断）/ 注入 / 不安全反序列化 / 访问控制
  - design：UI 一致性清单（仅清单，不自动修复）
  - 新增独立子脚本 `review-product.sh` / `review-eng.sh` / `review-security.sh` / `review-design.sh`
- **review 修复 bug**：`cmd_review` 末尾补 `_set_stage reviewed`，无致命问题时推进阶段（原实现只生成素材不推进）。
- **verify 多维增强**：从单维度（Requirement 数 vs tasks 勾选数）升级为四维结构化验证：
  ① spec 覆盖（Requirement → test 映射，复用 tasks.md）② 测试状态（复用 qa 逻辑）③ 文档同步（docs/ 修改时间）④ 提交规范（分支提交是否携带 VAPD）。空仓库友好。
- **qa web 集成**（不新增 label）：完全复用 `rules/workflow.md` 的「测试」命令；前端 web 工程经 SKILL.md 散文引导在「测试」中配置 agent-browser / playwright 驱动的 e2e，浏览器测试随 qa 自然执行，未配置时行为与原来一致。
- **qa SKILL.md 更新**：补充前端 web 工程 agent-browser 引导段；review 段改为「多视角自动推进」叙事。
- **测试**：`tests/code-compass/skill_native.bats` 新增 review 推进/阻断、verify 映射等回归用例。

## 实现中修复的真实缺陷

- `set -o pipefail` 下 `cmd | grep -q` 引发 SIGPIPE（退出 128）→ 改用全局 `_REVIEW_DIFF` + `grep ... <<< "$_REVIEW_DIFF"`（非管道）。
- 单条 `local a="$1" b="$a/..."` 在 `set -u` 下报未绑定变量 → 拆成两条 `local`。
- `set -e` 对返回非 0 的裸函数调用直接中止编排 → 编排入口改用 `if` / `||` 守卫捕获返回码。

## 验证

- `bash tests/code-compass/run_smoke.sh` → PASS=9 FAIL=0（无回归）
- 新增回归用例全绿：review 四视角推进到 reviewed / 硬编码密钥阻断 / verify 映射缺失失败 / 映射完整通过
- 实跑 `qa.sh → verified`、`review.sh → reviewed → summary` 阶段机全通

## 遗留（P1，已在 proposal 非目标声明）

- 部署流水线（/ship → /land-and-deploy → /canary）
- 操作护栏（careful / freeze 等价物，与 code-compass 的「方法论 guard」命名区分）
- review 自动修复深改（security/eng 高置信项的 `--fix` 开关）

## 提交

`feat: 升级 review/verify/qa 质量关为多视角可执行链（零依赖）`
