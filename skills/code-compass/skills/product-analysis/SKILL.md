---
name: product-analysis
description: >
   柏拉图式发问收敛需求并生成已确认 spec。运行 `code-compass product-analysis [name]` 或说"需求分析 / 设计一下 / 确定范围 / 出方案"时触发。
---

# product-analysis —— 八步需求分析与设计流程

目标不是立刻写代码，而是把模糊意图收敛成一份**已确认、可验证、自带实施计划**的 spec。
严格按以下 8 步推进，每步产出明确后再进入下一步。spec 存放于
`.harness/openspec/changes/<slug>/`。

## 触发条件

- 用户运行 `code-compass product-analysis [name]`
- 用户说"先做需求分析"、"设计一下"、"确定范围"、"出方案"
- `.harness/state/workflow-state.json` 的 `stage` 为 `idea` 或 `product-analysis`

## 工作目录约定

CLI 已创建 `.harness/openspec/changes/<slug>/`，含 `proposal.md` / `tasks.md` / `specs/`。
本流程的产出落点：

- `proposal.md`   —— Why：意图、档位、决策记录、非目标
- `specs/<capability>/spec.md` —— 目标能力 spec（按 `templates/spec.md` 规范）
- `tasks.md`      —— 实施计划（步骤 8 填充）

---

## 步骤 1 · 需求理解与诊断

- **复述意图**：用自己的话复述用户想做什么，请用户确认理解无误。
- **判定档位（tier）**：研究型 / 小特性 / 中特性 / 大特性 / 重构。档位决定后续探索深度与方案数量。
- **标记候选**：
  - *外部探索候选*：需要查官方文档 / 竞品 / 第三方 API / 社区方案的环节
  - *视觉候选*：涉及 UI / 交互 / 视觉对比，后续需截图（agent-browser）
- **捕获 VAPD 标识**：若用户在需求描述中**显式给定**了 VAPD 标识 ID
  （需求 `VR` 开头 / 缺陷 `VB` 开头 / 任务 `VT` 开头，如 `VR12345`、
  `VB2024`、`VT7788`），立即用 `code-compass vapd <ID>` 将其写入
  `.harness/state/workflow-state.json` 的 `vapd_id` 字段，供后续提交携带。
  用户未显式给定时**不要**臆造 ID。
- **输出诊断小结**：一句话问题本质 + 档位 + 候选标记（+ VAPD ID，若有），作为后续探索的输入。

## 档位（tier / track）与命令参数

`product-analysis` 通过 `--track` 选定档位，决定后续状态机阶段链（见 `config.json.tracks`）：

| track | 阶段链（裁剪后） | 适用 |
|--------|----------------|------|
| `research` | idea→product-analysis→planned→dev→summary | 研究型，探索后即收尾，不进实现链 |
| `small` | idea→…→implemented→qa→verified→summary | 小特性，跳过 `review` |
| `standard` | idea→…→verified→reviewed→summary | 中特性（**默认**） |
| `standard+` | 同 `standard` | 大特性，强调评审 |
| `refactor` | 同 `standard` | 重构 |

- 默认 `standard`；`status activate` 会按当前 track 裁剪"下一步"命令（如 `small` 在 `verified` 后提示收尾/wiki 而非 `review`）。
- 档位在创建变更工作区时写入 `workflow-state.json` 的 `track` 字段（`_set_track`）。

命令参数（全部可选，位置参数为变更名称）：

| 参数 | 形式 | 说明 |
|------|------|------|
| `[name]` | `product-analysis <name>` | 变更名称（kebab-case），交互式也会再问一次 |
| `--track <t>` | `--track standard+` | 选档位，默认 `standard`；非法值报错 |
| `--vapd <ID>` | `--vapd VR12345` | 显式记录 VAPD 标识（VR/VB/VT 开头） |
| `--append "文本"` | `--append "决策点"` / `--append <slug> "文本"` / 管道 | **仅追加**一条澄清/决策到 `.harness/issues.md`（单文件日志），不重建 spec；无 spec 也可累积 |
| `--force <name>` | `product-analysis --force c` | 跳过交互命名，直接脚手架 `proposal.md`/`tasks.md`/`specs/` 并置 `product-analysis` 阶段 |

> `--append` 把"澄清/决策"从八步流程里抽离：无需走完也能累积上下文到 `issues.md`；
> `--force` 在已想清楚时省去交互，直接拿到工作区。

## 步骤 2 · 并行探索（内部代码 + 外部资源）

- **内部**：用 `Task` 子代理并行扫描相关代码、现有 `specs/`、`.harness/openspec/specs/`、`docs/`，汇总：
  - 现有可复用模块 / 接口
  - 与本次需求冲突或重叠的既有 spec
  - 关键不确定点
- **外部**：对"外部探索候选"用 `websearch` / `webfetch` 查官方文档、社区方案、API 约定；
  对"视觉候选"用 `agent-browser` 截图留证。
- **汇总事实清单**，明确标注"已确认事实"与"待澄清假设"。

## 步骤 3 · 澄清问题（一次一个，不限轮数）

- **每轮只问一个问题**，等待用户回答后再问下一个；绝不一次性抛出问题列表。
- 优先级递进：目标 → 边界 → 约束 → 成功信号 → 非目标。
- 持续发问直到满足：**需求清晰、边界明确、非目标清楚、成功信号可观测**。
- 不急于给方案；澄清不充分时继续问。

## 步骤 4 · 对抗验证 + 提出 2~3 方案

- **对抗验证**：用结构化逐步推理复核步骤 2~3 的事实是否自洽、有无遗漏前提或矛盾假设。
- **给出 2~3 个候选方案**，每个含：思路、关键取舍、相对工作量、主要风险。
- **明确推荐**：给出推荐方案与理由（为什么它最好 / 最窄切口 / 风险最低）。
- **用户选定其一**；若都不满意，回到步骤 3 补充澄清后重提。

## 步骤 5 · 展示完整设计

基于选定方案，向用户**完整展示**设计，至少覆盖：

- 目标与非目标（边界）
- 架构 / 接口 / 数据模型
- 关键流程与边界场景
- 风险与缓解
- 成功信号（可观测）

用户确认设计后，方可进入生成。

## 步骤 6 · 生成 spec（罗盘到正确目录）

工作区已由 CLI 预置 spec 模板 `specs/<capability>/spec.md`，按以下方式填写：

1. **重命名能力目录**：将 `specs/<capability>/` 改名为真实能力名（kebab-case，如 `specs/user-auth/`）。
2. **填写 proposal.md**：填"问题本质 + 档位 + 决策记录 + 非目标 + 成功信号"。（Why）
3. **填写 specs/<capability>/spec.md**：基于模板，写 `## ADDED Requirements`，
   每条 `### Requirement: <名称>` 写"系统 SHALL ..."，并附 `#### Scenario:`（正常 + 异常）。
   模板规范见本仓库 `templates/spec.md`（CLI 已复制一份到变更工作区）。
4. **tasks.md**：先写粗略框架，步骤 8 再细化为实施计划。

路径务必落在 `.harness/openspec/changes/<slug>/` 下对应文件。

## 步骤 7 · Spec self-review + 对抗验证

- **inline 自检**：
  - 每条 Requirement 是否**可验证**？能否写出 Scenario？
  - Scenario 是否覆盖正常路径 + 异常/边界路径？
  - 是否与 `.harness/openspec/specs/` 中既有 spec 冲突？
  - 是否夹带了"非目标"内容？
- **对抗验证**：逐条对 spec 做对抗式审查——是否可验证、Scenario 是否覆盖正常+异常路径、
  是否与既有 spec 冲突、是否夹带非目标——输出问题清单。
- **闭环**：若存在需修改项，修订 spec 后**请用户再 review 一次**，直到用户认可。

## 步骤 8 · 交接 plans（唯一终态）

- 经用户确认 spec 后，用 `writing-plans` 将 Requirement 拆为可独立验证的任务，
  回填 `tasks.md`（含依赖关系、顺序、验收标准）。
- 这是 product-analysis 的**唯一终态**：交付"已确认 spec + 实施计划"。
- 将 `.harness/state/workflow-state.json` 的 `stage` 推进到 `planned`。
- 提示用户：运行 `code-compass dev <slug>` 进入实现（product-analysis 到此结束，不进入编码）。

---

## 边界

- product-analysis **止步于计划**：不写实现代码，编码交给 `dev`。
- 步骤 3 不限轮数，但以"需求清晰、边界明确"为停止条件，不要为了收敛而收敛。
