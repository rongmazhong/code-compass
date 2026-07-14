---
name: using-code-compass
description: >
   注册并启用 code-compass 个人 skill 库。运行 `code-compass using-code-compass` 或说"启用指南针 / 加载我的 skill 库"时触发。
---

# using-code-compass

启用 code-compass 个人 skill 库的总开关。运行后，agent 即可通过 `skill` 工具
加载 `init` / `product-analysis` / `dev` / `guard` 等 skill，并按 AGENTS.md 中的
「触发词 → 必调 skill」映射，在匹配场景自动或按需调用。

## 触发条件

- 用户运行 `code-compass using-code-compass`
- 用户说"启用 code-compass"、"加载我的 skill 库"、"接入指南针"
- 会话开始时希望启用本库的方法论编排（先分析后开发的强制约束）

## 执行流程

1. 运行 `code-compass using-code-compass`（CLI 会：）
    - 校验 code-compass 已全局安装到 `$CODE_COMPASS_SKILLS_DIR/code-compass`（默认 `~/.agents/skills/code-compass`）；本工具不创建任何软链
    - 若目标项目没有 `.harness/`，自动执行 `init`（注入强制约束段与 `rules/guard.md`）
    - 打印已注册 skill 列表与触发方式（各子 skill 直接读取 `skills/<name>/SKILL.md`）
2. 确认 AGENTS.md 中已注入 code-compass 强制约束段（init 负责）
3. 此后 agent 遇到匹配场景时，直接 `skill` 工具加载对应 `SKILL.md`
