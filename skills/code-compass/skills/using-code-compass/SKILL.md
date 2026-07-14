---
name: using-code-compass
description: >
    注册并启用 code-compass 个人 skill 库。运行 `code-compass using-code-compass` 或说"启用指南针 / 加载我的 skill 库 / using-code-compass"时触发。
---

# using-code-compass

启用 code-compass 个人 skill 库的**接入总入口**。agent 加载本 skill 后，应按下方
「执行流程」驱动：先判定项目是否已 init，未 init 则初始化；再判定并报告项目状态，
让 agent 据此给出下一步动作（而非仅描述性提示）。

## 触发条件

- 用户运行 `code-compass using-code-compass`
- 用户说"启用 code-compass"、"加载我的 skill 库"、"接入指南针"、"using-code-compass"
- 会话开始时希望启用本库的方法论编排（先分析后开发的强制约束）

## 执行流程（agent 据此行动）

1. 运行 `code-compass using-code-compass`（CLI 内部执行）：
   - **安装校验**：确认 code-compass 已全局安装到 `$CODE_COMPASS_SKILLS_DIR/code-compass`
     （默认 `~/.agents/skills/code-compass`）；缺失则提示 `npx skills add rongmazhong/code-compass`。
   - **init 校验（需求1）**：检测目标项目是否存在 `.harness/`；**不存在则自动执行 `init`**
     （生成 state/rules/openspec 与 docs/wiki，并注入 AGENTS.md 路由段）。
   - **AGENTS.md 校验（需求3）**：校验 `AGENTS.md` 是否含 code-compass 路由段，缺失则自动补。
   - **状态卡（需求2）**：读取 `.harness/state/workflow-state.json`，**内联打印状态卡**
     （stage / 关联 spec / 开发分支 / VAPD 标识 / 最近更新 + 下一步建议）。
2. agent 读取状态卡中的 `stage`，据此向用户给出下一步建议：
   - `idea` → 建议运行 `product-analysis` 收敛需求
   - `planned`+ → 可直接 `dev`（`guard` 已通过）
   - 其它阶段 → 按状态卡 `➡️ 下一步` 提示推进
3. 此后 agent 遇到匹配场景时，直接通过 `skill` 工具加载对应 `SKILL.md`。

## 设计要点

- 幂等：重复运行 `using-code-compass` 不会覆盖已有 `.harness/`、rules/ 或 AGENTS.md 段。
- 非交互安全：不在管道 / agent 调用中卡住等待输入；状态卡直接打印。
- 状态判定与 `guard` / `status` 共用同一 `workflow-state.json` 真源，结果一致。
