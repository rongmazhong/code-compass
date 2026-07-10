---
name: design
description: |
  通过柏拉图式（苏格拉底式）发问确定产品需求范围，并生成 OpenSpec 风格的 spec 文档。
  当用户运行 `code-compass design [name]`、或说"先做需求分析 / 设计一下 / 确定范围"时触发。
  融合 superpowers 的 brainstorming、gstack 的 office-hours 与 openspec 的 change 提案。
---

# design —— 柏拉图式发问，确定需求范围

目标不是立刻写代码，而是用一连串追问逼近"真正要解决的问题"，
把模糊的意图收敛成一份可验证的 spec（存放于 `openspec/changes/<slug>/`）。

## 触发条件

- 用户运行 `code-compass design [name]`
- 用户说"先设计一下"、"确定需求范围"、"这个功能怎么做"
- `.harness/workflow-state.json` 的 `stage` 为 `idea`

## 阶段前置

CLI 已创建 `openspec/changes/<slug>/`，含 `proposal.md` / `tasks.md` / `specs/`。
本 skill 负责把对话结论填入这些文件，并将 `stage` 推进到 `design` → `planned`。

## 柏拉图式发问流程（一次只问一个）

按以下层级递进，每层得到明确答复后再进入下一层。不要一次性抛出所有问题。

### 第一层：本质之问（What is it?）
- "你真正想解决的问题是什么？用一句话描述。"
- "如果不做这个，用户/你现在的替代方案是什么？痛点具体在哪？"
- 目的：剥离手段，锁定"问题本质"。

### 第二层：对象之问（For whom?）
- "谁会使用它？谁是首要用户？"
- "他们现在怎么完成这件事？最反感的环节是什么？"

### 第三层：边界之问（What is NOT?）
- "明确不做什么？哪些看似相关但其实超出范围？"
- "第一版（MVP）必须有的 3 个能力是什么？其余皆可后置。"

### 第四层：成功之问（How do we know it worked?）
- "怎样才算做成了？给出 1-2 个可观测的成功信号。"
- "有哪些必须不发生的坏事（失败/安全/性能红线）？"

### 第五层：形态之问（In what shape?）
- "它应以什么形态交付？CLI / 库 / 服务 / 文档？"
- "和现有 code-compass 的哪些部分交互？"

## 收敛与产出

发问结束后，将结论写入 `openspec/changes/<slug>/`：

1. **proposal.md**：记录"问题本质 + 范围边界 + 非目标 + 成功信号"，即 Why。
2. **specs/<capability>/spec.md**：用 delta 形式描述目标能力（Requirements 列表，每条含 `#### Requirement: <名称>` 与 `The system SHALL ...`，并附 `#### Scenario:`）。
3. **tasks.md**：把 spec 拆成实现步骤（对应 develop-workflow-rong 的 PLANNED 阶段）。

完成后提示用户运行 `code-compass dev <slug>` 进入实现。

## 与 superpowers / gstack / openspec 的对应

- **superpowers.brainstorming**：探索上下文、提澄清问题、给 2-3 方案、构建设计
- **gstack.office-hours**：六问逼出需求现实（status quo / 绝望细节 / 最窄切口）
- **openspec**：`changes/<slug>/` 的 proposal + specs delta + tasks 三件套
- **develop-workflow-rong**：design 完成后 `stage` 进入 `planned`，可由 dev 接续
