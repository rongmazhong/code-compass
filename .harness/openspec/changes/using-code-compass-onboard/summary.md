# 变更总结：using-code-compass 接入入口增强

> 由 code-compass summary 阶段生成（变更回顾 / 成果 / 后续）

## 变更回顾

本次优化目标是让 `code-compass using-code-compass` 从"仅安装+描述性提示"升级为
**确定性的接入校验入口**，覆盖三点需求：

1. 判定项目是否经 code-compass init，未 init 则自动初始化；
2. 判定并内联报告项目状态（阶段机）；
3. 校验并自动补全 AGENTS.md 路由段。

## 成果

- 新增辅助函数（幂等、纯 Bash）：
  - `_next_step`：依据 stage 推导下一步建议；
  - `_ensure_agents_md`：校验并补全 AGENTS.md 路由段，被 `cmd_use` 与 `cmd_init` 复用；
  - `_print_state_card`：内联打印状态卡（stage/spec/branch/VAPD/更新时间 + 下一步）。
- `cmd_use` 重写：安装校验 → init 判定（自动）→ AGENTS 校验 → 状态卡。
- `skills/code-compass/skills/using-code-compass/SKILL.md` 改为 agent 可执行指令。
- 提交：`f283131` `feat: using-code-compass 接入入口…`（19 文件，+641/-24）。

## 验证

- 已 init 项目：检测 `.harness` 存在，跳过 init，打印状态卡；
- 未 init 项目：自动 init + AGENTS 注入 + 状态卡；
- 幂等：连续运行不重复 init / 不重复包裹 AGENTS；
- 未知 stage：状态卡给出"手动编辑"提示，不报错。

## 后续

- 可考虑为 CLI 增加独立 smoke 测试脚本（当前靠手动验证）；
- `wiki` 可重建 docs/ 以反映本变更；
- 若接入更多 agent 平台，扩展"安装校验"的 skills 目录探测。
