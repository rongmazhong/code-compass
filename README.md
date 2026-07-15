# code-compass

个人 skill 库，提供一套 spec 驱动、状态机编排的开发方法论。**核心是 skill 驱动**：
agent 通过 skill 工具加载对应子 `SKILL.md`，按其中的方法论散文行动；`scripts/*.sh`
只是子 skill 在散文中指示执行的机械工具层，并非主入口。
**方法论是默认硬约束**：动手写代码前必须先经 `product-analysis` 子 skill 生成已确认 spec，
`guard` 子 skill 会在阶段不符时拦截偏离。

## 安装与启用

本 skill 通过 skills 注册表分发，安装后完整工具位于 `~/.agents/skills/code-compass/`：

```bash
npx skills add rongmazhong/code-compass
```

安装后加载 `using-code-compass` 子 skill 校验安装并完成当前项目初始化。

## 核心子 skill

> agent 遇到匹配场景时，用 skill 工具加载下表对应的 `SKILL.md`；其散文会指示何时调
> `scripts/*.sh` 机械工具完成确定性步骤。

| 子 skill | SKILL.md | 作用 |
|----------|-----------|------|
| `using-code-compass` | `skills/using-code-compass/SKILL.md` | 注册并启用库（校验已全局安装，并确保项目已 init） |
| `init` | `skills/init/SKILL.md` | 初始化 `.harness/`（含 state/rules/openspec），注入 AGENTS.md |
| `product-analysis` | `skills/product-analysis/SKILL.md` | 柏拉图式发问 → 需求范围 → spec 文档 |
| `dev` | `skills/dev/SKILL.md` | 基于 spec 的开发实现（自动 git worktree 隔离） |
| `guard` | `skills/guard/SKILL.md` | 闸门校验：当前阶段是否允许动手，偏离则拦截 |
| `status` | `skills/status/SKILL.md` | 查看状态 / 激活当前阶段自动化流程 |
| `commit` | `skills/commit/SKILL.md` | 按 `<type>: #{VAPD_ID}#<描述>` 规范提交（含阶段校验） |
| `vapd` | `skills/commit/SKILL.md` | 记录/查看 VAPD 标识（VR需求/VB缺陷/VT任务） |
| `wiki` | `skills/wiki/SKILL.md` | 更新/重建项目 wiki（docs/） |
| `review` / `qa` / `verify` | `skills/{review,qa,verify}/SKILL.md` | QA 测试、覆盖核对、审查包生成 |

（worktree 管理由 `dev`/`guard` 散文按需调用 `scripts/worktree.sh`，无需单独加载。）

## 使用方式

方法论是**默认硬约束**：任何代码改动意图，先走 `product-analysis → planned → dev` 阶段机，
未生成 spec 不得直接编码。agent 依据用户意图加载对应子 skill：
- 新建/接入项目 → 加载 `init`（注入强制约束、引导补全 overview、生成 rules/guard.md）
- 需求不明确 / 用户说"新功能、做客户端、实现 X" → 加载 `product-analysis`（柏拉图式发问）
- 动手前闸门校验 → 加载 `guard`（偏离会拦截，exit 非 0）
- 已有 spec 要落地 → 加载 `dev`（阶段未到 planned 会被拦截，可用 `dev --force` 豁免）

每个子 skill 的详细方法论见 `skills/<name>/SKILL.md`。阶段进度统一维护在
`.harness/state/workflow-state.json`，阶段链：
`idea → product-analysis → planned → dev → implemented → qa → verified → reviewed → summary`。

## 设计融合

> 以下为方法论**灵感来源**（可选增强，非强制依赖）：code-compass 已将其内化为自包含的 skill 工作流，加载子 skill 即可跑通全流程，无需另行安装外部 skill 库。

- **superpowers**：方法论优先（先理解再实现、TDD、系统化调试、验证）
- **gstack**：QA 用 agent-browser，审查用 review + codex，发布用 /ship
- **OpenSpec**：`.harness/openspec/changes/<slug>/` 的 proposal + tasks + spec delta
- **develop-workflow-rong**：状态机阶段即编排依据，支持断点续跑
